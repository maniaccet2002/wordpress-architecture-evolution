aws_region = "us-east-1"
vpc_cidr = "10.10.0.0/16"
wordpress_db_name = "wordpressdb"
wordpress_db_user = "wordpress"
wordpress_db_address = "localhost"
instance_type = "t2.micro"
wordpress_ec2_instance = true
deployment_type = "single_instance"
wordpress_elastic_ip = true
wordpress_efs = false
user_data_file = "./ec2/wordpress_single_instance.sh"