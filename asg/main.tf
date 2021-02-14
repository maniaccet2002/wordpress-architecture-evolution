
#fetch the latest amazon linux 2 AMI
data "aws_ssm_parameter" "latestami" {
   name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}
# IAM role to enable access to EFS and Auto scaling lifecycle hooks
resource "aws_iam_role" "wordpress_ec2_role" {
  name = "wordpress_ec2_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
    tag-key = "ec2_role"
  }
}
resource "aws_iam_role_policy_attachment" "efs_policy" {
  role = aws_iam_role.wordpress_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonElasticFileSystemClientFullAccess"
}
resource "aws_iam_role_policy" "asg_lifecyclehook_policy" {
  name = "ASG_Lifecyclehook_Policy"
  role = aws_iam_role.wordpress_ec2_role.name
  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "autoscaling:CompleteLifecycleAction",
          "autoscaling:RecordLifecycleActionHeartbeat"
        ],
        "Effect": "Allow",
        "Resource": "*"
      }
    ]
  }
  EOF
}
# EC2 instance profile
resource "aws_iam_instance_profile" "wordpress_instance_profile" {
  role = aws_iam_role.wordpress_ec2_role.name
  name = "wordpress_instance_profile"
}
#Launch Template for autoscaling group
resource "aws_launch_template" "wordpress_lt" {
  name = "wordpress_lt"
  instance_type = var.instance_type
  image_id = data.aws_ssm_parameter.latestami.value
  vpc_security_group_ids = [ var.wordpress_public_sg ]
  update_default_version = true
  iam_instance_profile {
    name = aws_iam_instance_profile.wordpress_instance_profile.name
  } 
  user_data = base64encode(templatefile(var.user_data_file,{Region=var.aws_region,DBName=var.wordpress_db_name,DBUser=var.wordpress_db_user,DBPassword=var.wordpress_db_password,DBEndpoint=var.wordpress_db_address,EFSFSID=var.wordpress_efsid}))
}
# Auto Scaling Group
resource "aws_autoscaling_group" "wordpress_asg" {
  name = "wordpress_asg"
  vpc_zone_identifier = var.public_subnet_list
  desired_capacity = var.asg_desired_capacity
  max_size = var.asg_max_size
  min_size = var.asg_min_size
  health_check_grace_period = 60
  health_check_type = var.asg_health_check_type
  target_group_arns = [aws_lb_target_group.wordpress_target_grp.arn]
  launch_template {
    id = aws_launch_template.wordpress_lt.id
    version = aws_launch_template.wordpress_lt.latest_version
  }
  #lifecycle hook which waits for the signal from the EC2 instance once the user data script is executed successfully
  initial_lifecycle_hook {
    name = "wordpress-instance-launch-hook"
    default_result = "ABANDON"
    heartbeat_timeout = 600
    lifecycle_transition = "autoscaling:EC2_INSTANCE_LAUNCHING"
  }
  instance_refresh {
    strategy = "Rolling"
    preferences {
      instance_warmup = 30
      min_healthy_percentage = 50
    }
  }
}
# Auto scaling policy to scale out the EC2 instances based on the CPU utilization
resource "aws_autoscaling_policy" "wordpress_scale_out" {
    name = "wordpress_scale_out_cpu"
    autoscaling_group_name = aws_autoscaling_group.wordpress_asg.name
    policy_type = "SimpleScaling"
    adjustment_type = "ChangeInCapacity"
    cooldown = 300
    scaling_adjustment = 1
}
# Cloudwatch alarm to be triggered when CPU utilization is more than the set threshold
 resource "aws_cloudwatch_metric_alarm" "wordpress_asg_cpu_out" {
   alarm_name = "wordpress_asg_cpu_out"
   comparison_operator = "GreaterThanOrEqualToThreshold"
   evaluation_periods = 1
   metric_name = "CPUUtilization"
   namespace = "AWS/EC2"
   period = 300
   statistic = "Average"
   threshold = var.cpu_scaleout_threshold
   alarm_description = "Alarm for ASG scale out action"
   dimensions = {
     "AutoScalingGroupName" = aws_autoscaling_group.wordpress_asg.name
   }
   alarm_actions = [ aws_autoscaling_policy.wordpress_scale_out.arn ]
 }
 # Auto scaling policy to scale IN the EC2 instances based on the CPU utilization
 resource "aws_autoscaling_policy" "wordpress_scale_in" {
    name = "wordpress_scale_in_cpu"
    autoscaling_group_name = aws_autoscaling_group.wordpress_asg.name
    policy_type = "SimpleScaling"
    adjustment_type = "ChangeInCapacity"
    cooldown = 300
    scaling_adjustment = -1
}
# Cloudwatch alarm to be triggered when CPU utilization is less than the set threshold
 resource "aws_cloudwatch_metric_alarm" "wordpress_asg_cpu_in" {
   alarm_name = "wordpress_asg_cpu_in"
   comparison_operator = "LessThanOrEqualToThreshold"
   evaluation_periods = 1
   metric_name = "CPUUtilization"
   namespace = "AWS/EC2"
   period = 300
   statistic = "Average"
   threshold = var.cpu_scalein_threshold
   alarm_description = "Alarm for ASG scale out action"
   dimensions = {
     "AutoScalingGroupName" = aws_autoscaling_group.wordpress_asg.name
   }
   alarm_actions = [ aws_autoscaling_policy.wordpress_scale_in.arn ]
 }
 # Application load balancer
resource "aws_lb" "wordpress_alb" {
  name = "wordpress-alb"
  internal = false
  load_balancer_type = "application"
  security_groups = [var.wordpress_public_sg ]
  subnets = var.public_subnet_list 
}
# Target group for the load balancer
resource "aws_lb_target_group" "wordpress_target_grp" {
  name = "wordpress-target-group"
  port = 80
  protocol = "HTTP"
  vpc_id = var.vpc_id
  health_check {
    interval = 30
    path = "/"
    healthy_threshold = 2
    unhealthy_threshold = 10
    matcher = "200,302"
  }
}
# Listener configuration for the load balancer
resource "aws_lb_listener" "wordpress_listener" {
  load_balancer_arn = aws_lb.wordpress_alb.arn
  port = 80
  protocol = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.wordpress_target_grp.arn
  }
}