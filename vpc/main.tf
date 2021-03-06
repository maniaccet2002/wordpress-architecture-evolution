locals {
   cidr_list = [for cidr_block in cidrsubnets(var.vpc_cidr,2,2,2,2) : cidrsubnets(cidr_block,2,2,2,2)]
 }
 # Create a custom VPC
resource "aws_vpc" "myvpc" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  enable_dns_hostnames = "true"
  assign_generated_ipv6_cidr_block = "true"

  tags = {
    Name = "wordpress-vpc"
  }
  lifecycle {
    create_before_destroy = true
  }
}
# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id
}

#Public subnets on 4 different Availability Zones
resource "aws_subnet" "public" {
  count = length(local.cidr_list[0])
  vpc_id = aws_vpc.myvpc.id
  cidr_block = local.cidr_list[0][count.index] 
  map_public_ip_on_launch = true
  availability_zone = var.az_list[count.index]
  tags = {
    Name = "public-web-${split("-",var.az_list[count.index])[2]}"
  }
}
#Private subnets on 4 different Availability Zones for application layer
resource "aws_subnet" "private-app" {
  count = length(local.cidr_list[1])
  vpc_id = aws_vpc.myvpc.id
  cidr_block = local.cidr_list[1][count.index] 
  map_public_ip_on_launch = false
  availability_zone = var.az_list[count.index]
  tags = {
    Name = "private-app-${split("-",var.az_list[count.index])[2]}"
  }
}
#Private subnets on 4 different Availability Zones for database layer
resource "aws_subnet" "private-db" {
  count = length(local.cidr_list[2])
  vpc_id = aws_vpc.myvpc.id
  cidr_block = local.cidr_list[2][count.index] 
  map_public_ip_on_launch = false
  availability_zone = var.az_list[count.index]
  tags = {
    Name = "private-db-${split("-",var.az_list[count.index])[2]}"
  }
}
#Private subnets on 4 different Availability Zones 
resource "aws_subnet" "reserved" {
  count = length(local.cidr_list[3])
  vpc_id = aws_vpc.myvpc.id
  cidr_block = local.cidr_list[3][count.index] 
  map_public_ip_on_launch = false
  availability_zone = var.az_list[count.index]
  tags = {
    Name = "reserved-${split("-",var.az_list[count.index])[2]}"
  }
}
# Route table configurations
resource "aws_route_table"  "public_route_table" {
  vpc_id = aws_vpc.myvpc.id
}
resource "aws_route" "public_default_route" {
  route_table_id = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id
}
resource "aws_route_table_association" "public_route_assoc" {
  count = length(local.cidr_list[0])
  subnet_id = aws_subnet.public.*.id[count.index]
  route_table_id = aws_route_table.public_route_table.id
}
resource "aws_default_route_table" "private_route" {
  default_route_table_id = aws_vpc.myvpc.default_route_table_id  
}
# Security group which allows public access on port 80 for HTTP and 22 for SSH
resource "aws_security_group" "wordpress_public_sg" {
  name = "wordpress_public_sg"
  description = "Wordpress Public Security Group"
  vpc_id = aws_vpc.myvpc.id
  ingress  {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}
# Security group for RDS cluster which allows connection on port 3306 from the application layer
resource "aws_security_group" "wordpress_rds_sg" {
  name = "wordpress_rds_sg"
  description = "Wordpress RDS Security Group"
  vpc_id = aws_vpc.myvpc.id
  ingress  {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    security_groups = [aws_security_group.wordpress_public_sg.id]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}
#Security group for EFS which allows connection on port 2049 from the application layer
resource "aws_security_group" "wordpress_efs_sg" {
  name = "wordpress_efs_sg"
  description = "Wordpress EFS Security Group"
  vpc_id = aws_vpc.myvpc.id
  ingress  {
    from_port = 2049
    to_port = 2049
    protocol = "tcp"
    security_groups = [aws_security_group.wordpress_public_sg.id]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
  } 
}