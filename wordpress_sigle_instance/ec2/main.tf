data "aws_ssm_parameter" "latestami" {
   name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
 }
locals {
   security_groups = {
     public = {
       name = "public_sg"
       description = "Security Group for public Access"
       ingress = {
         ssh = {
           from = 22
           to = 22
           protocol = "tcp"
         },
         http = {
           from = 80
           to = 80
           protocol = "tcp"
         }
       }
     }
   }
 }
resource "aws_instance" "wordpress" {
  ami = data.aws_ssm_parameter.latestami.value
  instance_type = "t2.micro"
  subnet_id = var.public_subnet_id
  security_groups = [aws_security_group.wordpress_sg["public"].id]
  user_data = file("./ec2/wordpress.sh")
  }
resource "aws_security_group" "wordpress_sg" {
  for_each = local.security_groups
  name = each.value.name
  description = each.value.description
  vpc_id = var.vpc_id
  dynamic "ingress" {
    for_each = each.value.ingress
    content {
      from_port = ingress.value.from
      to_port = ingress.value.to
      protocol = ingress.value.protocol
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}