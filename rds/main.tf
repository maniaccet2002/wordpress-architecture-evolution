locals {
  multi_az = var.deployment_type == "rds_multi_az" ? true : false
  instance_class = var.deployment_type == "rds_multi_az" ? "db.t3.micro" : "db.t2.micro"
  rds_az = var.deployment_type == "rds_multi_az" ? null : "us-east-1a"
}
resource "aws_db_subnet_group" "wordpress_rds_sg" {
  name = "wordpress_rds_sg"
  subnet_ids = var.db_subnet_list
  tags = {
      Name = "Wordpress RDS Security Group"
  }
}
resource "aws_db_instance" "wordpress_rds_instance" {
  allocated_storage = 20
  storage_type         = "gp2"
  engine = "mysql"
  engine_version = "5.6.46"
  instance_class       = local.instance_class
  identifier = var.rds_db_name
  name = var.rds_db_name
  username = var.rds_db_user
  password = var.rds_db_password
  db_subnet_group_name = aws_db_subnet_group.wordpress_rds_sg.name
  vpc_security_group_ids = [var.wordpress_rds_sg]
  skip_final_snapshot = true
  availability_zone = local.rds_az
  multi_az = local.multi_az
}