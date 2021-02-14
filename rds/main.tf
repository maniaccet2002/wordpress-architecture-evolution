#Create RDS Subnet group
resource "aws_db_subnet_group" "wordpress_rds_sg" {
  name = "wordpress_rds_sg"
  subnet_ids = var.db_subnet_list
  tags = {
      Name = "Wordpress RDS Security Group"
  }
}
# Create Mysql RDS cluster and instance
resource "aws_db_instance" "wordpress_rds_instance" {
  allocated_storage = var.rds_allocated_storage
  storage_type         = var.rds_storage_type
  engine = var.rds_db_engine
  engine_version = var.rds_db_engine_version
  instance_class       = var.rds_instance_class
  identifier = var.rds_db_name
  name = var.rds_db_name
  username = var.rds_db_user
  password = var.rds_db_password
  db_subnet_group_name = aws_db_subnet_group.wordpress_rds_sg.name
  vpc_security_group_ids = [var.wordpress_rds_sg]
  skip_final_snapshot = true
  availability_zone = var.availability_zone
  multi_az = var.multi_az
}