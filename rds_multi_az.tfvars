aws_region = "us-east-1"
vpc_cidr = "10.10.0.0/16"
wordpress_db_name = "wordpressdb"
wordpress_db_user = "wordpress"
instance_type = "t2.micro"
wordpress_efsid = null
wordpress_ec2_instance = true
wordpress_rds_instance = true
wordpress_elastic_ip = true
wordpress_efs = false
user_data_file = "./ec2/wordpress_ec2_rds.sh"
rds_db_engine = "mysql"
rds_db_engine_version = "5.6.46"
rds_instance_class = "db.t3.micro"
multi_az = true
rds_storage_type = "gp2"
rds_allocated_storage = 20