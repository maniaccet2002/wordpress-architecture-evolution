#fetch the latest amazon linux 2 AMI
data "aws_ssm_parameter" "latestami" {
   name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}
# Create EC2 instance role to enable access to EFS file system
resource "aws_iam_role" "wordpress_ec2_role" {
  count = var.wordpress_efs == true ? 1 : 0
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
  count = var.wordpress_efs == true ? 1 : 0
  role = aws_iam_role.wordpress_ec2_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonElasticFileSystemClientFullAccess"
}
resource "aws_iam_instance_profile" "wordpress_instance_profile" {
  count = var.wordpress_efs == true ? 1 : 0
  role = aws_iam_role.wordpress_ec2_role[0].name
  name = "wordpress_instance_profile"
}
# Create EC2 instance
resource "aws_instance" "wordpress" {
  ami = data.aws_ssm_parameter.latestami.value
  instance_type = var.instance_type
  subnet_id = var.public_subnet_id
  vpc_security_group_ids = [var.wordpress_public_sg]
  iam_instance_profile = var.wordpress_efs == true ? aws_iam_instance_profile.wordpress_instance_profile[0].name : null
  user_data = templatefile(var.user_data_file,{DBName=var.wordpress_db_name,DBUser=var.wordpress_db_user,DBPassword=var.wordpress_db_password,DBEndpoint=var.wordpress_db_address,EFSFSID=var.wordpress_efsid})
}
# Create Elastic IP
resource "aws_eip" "eip" {
    count = var.wordpress_elastic_ip == true ? 1 : 0
    instance = aws_instance.wordpress.id
    vpc = true
}