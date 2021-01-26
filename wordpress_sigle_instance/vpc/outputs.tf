output "vpcid" {
  value = aws_vpc.myvpc.id
  description = "VPC ID"
}
output "public-subnet-1a" {
  value = [for value in aws_subnet.public: value.id if value.availability_zone == "us-east-1a"][0]
  description = "ID for public subnet on AZ 1a"
}