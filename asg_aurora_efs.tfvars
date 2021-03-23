aws_region = "us-east-1"
vpc_cidr = "10.10.0.0/16"
wordpress_db_name = "wordpressdb"
wordpress_db_user = "wordpress"
instance_type = "t2.micro"
wordpress_ec2_instance = false
wordpress_autoscaling = true
wordpress_rds_instance = false
wordpress_efs = true
wordpress_aurora = true
wordpress_elastic_ip = false
user_data_file = "./asg/wordpress_ec2_rds_efs.sh"
#rds_db_engine = "mysql"
#rds_db_engine_version = "5.6.46"
#rds_instance_class = "db.t3.micro"
#multi_az = true
#rds_storage_type = "gp2"
#rds_allocated_storage = 20
efs_performance_mode="generalPurpose"
efs_throughput_mode = "bursting"
efs_encryption = true
asg_desired_capacity = 1
asg_max_size = 3
asg_min_size = 1
asg_health_check_type = "ELB"
cpu_scaleout_threshold = 40
cpu_scalein_threshold = 20
aurora_instance_class = "db.t3.small"
aurora_db_engine = "aurora"
aurora_db_engine_version = "5.6.mysql_aurora.1.22.2"