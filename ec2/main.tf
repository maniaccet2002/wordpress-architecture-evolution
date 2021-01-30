data "aws_ssm_parameter" "latestami" {
   name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
 }

locals {
  user_data_file = var.deployment_type == "single_instance" ? "./ec2/wordpress_single_instance.sh" : "./ec2/wordpress_ec2_rds.sh"
  db_endpoint = var.deployment_type == "single_instance" ? "localhost" : var.wordpress_db_address
}
resource "aws_instance" "wordpress" {
  ami = data.aws_ssm_parameter.latestami.value
  instance_type = "t2.micro"
  subnet_id = var.public_subnet_id
  security_groups = [var.wordpress_public_sg]
  user_data = templatefile(local.user_data_file,{DBName=var.wordpress_db_name,DBUser=var.wordpress_db_user,DBPassword=var.wordpress_db_password,DBEndpoint=local.db_endpoint})

  }
resource "aws_eip" "eip" {
    instance = aws_instance.wordpress.id
    vpc = true
  }
resource "aws_launch_template" "wordpress_lt" {
  name = "wordpress_lt"
  instance_type = "t2.micro"
  image_id = data.aws_ssm_parameter.latestami.value
  network_interfaces {
    associate_public_ip_address = true
    subnet_id = var.public_subnet_id
    security_groups = [ var.wordpress_public_sg ]
  }
  user_data = base64encode(templatefile(local.user_data_file,{DBName=var.wordpress_db_name,DBUser=var.wordpress_db_user,DBPassword=var.wordpress_db_password,DBEndpoint=local.db_endpoint}))
}