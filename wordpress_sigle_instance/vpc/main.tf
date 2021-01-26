locals {
   cidr_list = [for cidr_block in cidrsubnets(var.vpc_cidr,2,2,2,2) : cidrsubnets(cidr_block,2,2,2,2)]
 }
 locals {
   vpc_az_list = slice(var.az_list,0,4)
 }
resource "random_integer" "random" {
  min = 1
  max = 100
 }
resource "aws_vpc" "myvpc" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  enable_dns_hostnames = "true"
  assign_generated_ipv6_cidr_block = "true"

  tags = {
    Name = "myvpc-${random_integer.random.id}"
  }
  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id
}

resource "aws_subnet" "public" {
  count = length(local.cidr_list[0])
  vpc_id = aws_vpc.myvpc.id
  cidr_block = local.cidr_list[0][count.index] 
  map_public_ip_on_launch = true
  availability_zone = local.vpc_az_list[count.index]
  tags = {
    Name = "public-web-${split("-",local.vpc_az_list[count.index])[2]}"
  }
}
resource "aws_subnet" "private-app" {
  count = length(local.cidr_list[1])
  vpc_id = aws_vpc.myvpc.id
  cidr_block = local.cidr_list[1][count.index] 
  map_public_ip_on_launch = false
  availability_zone = local.vpc_az_list[count.index]
  tags = {
    Name = "private-app-${split("-",local.vpc_az_list[count.index])[2]}"
  }
}
resource "aws_subnet" "private-db" {
  count = length(local.cidr_list[2])
  vpc_id = aws_vpc.myvpc.id
  cidr_block = local.cidr_list[2][count.index] 
  map_public_ip_on_launch = false
  availability_zone = local.vpc_az_list[count.index]
  tags = {
    Name = "private-db-${split("-",local.vpc_az_list[count.index])[2]}"
  }
}
resource "aws_subnet" "reserved" {
  count = length(local.cidr_list[3])
  vpc_id = aws_vpc.myvpc.id
  cidr_block = local.cidr_list[3][count.index] 
  map_public_ip_on_launch = false
  availability_zone = local.vpc_az_list[count.index]
  tags = {
    Name = "reserved-${split("-",local.vpc_az_list[count.index])[2]}"
  }
}

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