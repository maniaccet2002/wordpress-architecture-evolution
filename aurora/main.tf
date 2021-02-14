# Aurora Cluster
resource "aws_rds_cluster" "wordpress_aurora_cluster" {
    cluster_identifier = "wordpress-aurora-cluster"
    availability_zones = slice(var.aurora_az_list,0,3)
    database_name = var.aurora_db_name
    master_username = var.aurora_db_user
    master_password = var.aurora_db_password
    db_subnet_group_name = aws_db_subnet_group.wordpress_aurora_sg.name
    skip_final_snapshot  = true
    vpc_security_group_ids = [var.aurora_security_group]
}
# Database subnet group
resource "aws_db_subnet_group" "wordpress_aurora_sg" {
  name = "wordpress_aurora_sg"
  subnet_ids = var.db_subnet_list
  tags = {
      Name = "Wordpress Aurora Security Group"
  }
}
# Aurora database instance
resource "aws_rds_cluster_instance" "wordpress_aurora_instance" {
    count = 3
    identifier = "wordpress-instance-${count.index}"
    cluster_identifier = aws_rds_cluster.wordpress_aurora_cluster.id
    engine = var.aurora_db_engine
    engine_version = var.aurora_db_engine_version
    instance_class = var.aurora_instance_class
    db_subnet_group_name = aws_db_subnet_group.wordpress_aurora_sg.name
}