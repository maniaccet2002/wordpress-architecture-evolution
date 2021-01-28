data "aws_ssm_parameter" "latestami" {
   name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
 }
# resource "aws_iam_role" "wordpress_ec2_role" {
#   name = "wordpress_ec2_role"
#   assume_role_policy = <<-EOF
#   {
#     "Version": "2012-10-17",
#     "Statement": [
#       {
#         "Action": "sts:AssumeRole",
#         "Principal": {
#           "Service": "ec2.amazonaws.com"
#         },
#         "Effect": "Allow",
#         "Sid": ""
#       }
#     ]
#   }
#   EOF
# }
# resource "aws_iam_role_policy" "wordpress_rds_role_policy" {
#   name = "wordpress_rds_policy"
#   role = aws_iam_role.wordpress_ec2_role.id
#   policy = <<-EOF
#   {
#     "Version": "2012-10-17",
#     "Statement": [
#       {
#         "Action": "rds:*",
#         "Effect": "Allow",
#         "Resource": "arn:aws:rds:us-east-1:429722698419:db:wordpressdb"
#       }
#     ]
#   }
#   EOF
# }
# resource "aws_iam_instance_profile" "wordpress_rds_instance_profile" {
#   name = "wordpress_rds_instance_profile"
#   role = aws_iam_role.wordpress_ec2_role.name
# }
locals {
  user_data_file = var.deployment_type == "single_instance" ? "./ec2/wordpress_single_instance.sh" : "./ec2/wordpress_ec2_rds.sh"
  db_endpoint = var.deployment_type == "single_instance" ? "localhost" : var.wordpress_db_address
}
resource "aws_instance" "wordpress" {
  ami = data.aws_ssm_parameter.latestami.value
  instance_type = "t2.micro"
  subnet_id = var.public_subnet_id
  security_groups = [var.wordpress_public_sg]
  #iam_instance_profile = aws_iam_instance_profile.wordpress_rds_instance_profile.name
  user_data = templatefile(local.user_data_file,{DBName=var.wordpress_db_name,DBUser=var.wordpress_db_user,DBPassword=var.wordpress_db_password,DBEndpoint=local.db_endpoint})
  }
