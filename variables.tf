variable "aws_region" {
    default = "us-east-1"
}
variable "vpc_cidr" {
    default = "10.10.0.0/16"
}
variable "wordpress_db_name" {
    default = "wordpressdb"
}
variable "wordpress_db_user" {
    default = "wordpress"
}
variable "wordpress_db_password" {
    description = "Password for the Wordpress Database"
    sensitive = true
}
variable "wordpress_db_address" {
    default = "localhost"
}
variable "wordpress_efsid" {
    default = null
}
variable "deployment_type" {
    default = "single_instance"
}
variable "wordpress_ec2_instance" {
    default = false
}
variable "wordpress_elastic_ip" {
    default = false
}
variable "instance_type" {
    default = "t2.micro"
}
variable "user_data_file" {}
variable "rds_db_engine" {
    default = "mysql"
}
variable "rds_db_engine_version" {
    default = "5.6.46"
}
variable "rds_instance_class" {
    default = "db.t2.micro"
}
variable "multi_az" {
    default = false
}
# variable "availability_zone" {
#     default = "us-east-1a"    
# }
variable "rds_storage_type" {
    default = "gp2"
}
variable "rds_allocated_storage" {
    default = 20
}
variable "wordpress_rds_instance" {
    default = false
}
variable "efs_performance_mode" {
    default = "generalPurpose"
}
variable "efs_throughput_mode" {
    default = "bursting"
}
variable "efs_encryption" {
    default = true
}
variable "wordpress_efs" {
    default = false
}
variable "asg_desired_capacity" {
    default = 1
}
variable "asg_max_size" {
    default = 1
}
variable "asg_min_size" {
    default = 1
}
variable "asg_health_check_type" {
    default = "ELB"
}
variable "cpu_scaleout_threshold" {
    default = 80
}
variable "cpu_scalein_threshold" {
    default = 20
}
variable "wordpress_autoscaling" {
    default = false
}
variable "wordpress_aurora" {
    default = false
}
variable "aurora_db_engine" {
    default = "aurora"
}
variable "aurora_db_engine_version" {
    default =  "5.6.mysql_aurora.1.22.2"
}
variable "aurora_instance_class" {
    default = "db.t3.small"
}