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
    default = "wordpress"
}
variable "deployment_type" {
    default = "rds_multi_az"
}