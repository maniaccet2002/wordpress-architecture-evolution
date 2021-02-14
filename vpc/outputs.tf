output "vpcid" {
  value = aws_vpc.myvpc.id
  description = "VPC ID"
}
output "public-web-1a" {
  value = [for value in aws_subnet.public: value.id if value.availability_zone == "us-east-1a"][0]
  description = "ID for public subnet on AZ 1a"
}
output "public-web-1b" {
  value = [for value in aws_subnet.public: value.id if value.availability_zone == "us-east-1b"][0]
  description = "ID for public subnet on AZ 1a"
}
output "public-web-1c" {
  value = [for value in aws_subnet.public: value.id if value.availability_zone == "us-east-1c"][0]
  description = "ID for public subnet on AZ 1a"
}
output "public-web-1d" {
  value = [for value in aws_subnet.public: value.id if value.availability_zone == "us-east-1d"][0]
  description = "ID for public subnet on AZ 1a"
}
output "private-app-1a" {
  value = [for value in aws_subnet.private-app: value.id if value.availability_zone == "us-east-1a"][0]
  description = "ID for public subnet on AZ 1a"
}
output "private-app-1b" {
  value = [for value in aws_subnet.private-app: value.id if value.availability_zone == "us-east-1b"][0]
  description = "ID for public subnet on AZ 1a"
}
output "private-app-1c" {
  value = [for value in aws_subnet.private-app: value.id if value.availability_zone == "us-east-1c"][0]
  description = "ID for public subnet on AZ 1a"
}
output "private-app-1d" {
  value = [for value in aws_subnet.private-app: value.id if value.availability_zone == "us-east-1d"][0]
  description = "ID for public subnet on AZ 1a"
}
output "private-db-1a" {
  value = [for value in aws_subnet.private-db: value.id if value.availability_zone == "us-east-1a"][0]
  description = "ID for public subnet on AZ 1a"
}
output "private-db-1b" {
  value = [for value in aws_subnet.private-db: value.id if value.availability_zone == "us-east-1b"][0]
  description = "ID for public subnet on AZ 1a"
}
output "private-db-1c" {
  value = [for value in aws_subnet.private-db: value.id if value.availability_zone == "us-east-1c"][0]
  description = "ID for public subnet on AZ 1a"
}
output "private-db-1d" {
  value = [for value in aws_subnet.private-db: value.id if value.availability_zone == "us-east-1d"][0]
  description = "ID for public subnet on AZ 1a"
}
output "wordpress_public_sg" {
  value = aws_security_group.wordpress_public_sg.id
}
output "wordpress_rds_sg" {
  value = aws_security_group.wordpress_rds_sg.id
}
output "wordpress_efs_sg" {
  value = aws_security_group.wordpress_efs_sg.id
}