# fetch 4 availability zone names
data "aws_availability_zones" "available" {}
locals {
  az_list = slice(data.aws_availability_zones.available.names,0,4)
}
#Module to create all VPC related configurations
module "wordpress_vpc" {
    source = "./vpc"
    vpc_cidr = var.vpc_cidr
    az_list = local.az_list
}
#Module to create EC2 instance. will be skipped if autoscaling group is enabled
module "wordpress_ec2_instance" {
    count =  var.wordpress_ec2_instance == true ? 1 : 0
    source = "./ec2"
    vpc_id = module.wordpress_vpc.vpcid
    public_subnet_id = module.wordpress_vpc.public-web-1a
    wordpress_public_sg = module.wordpress_vpc.wordpress_public_sg
    wordpress_db_name = var.wordpress_db_name
    wordpress_db_user = var.wordpress_db_user
    wordpress_db_password = var.wordpress_db_password
    wordpress_db_address = var.wordpress_rds_instance == true ? module.wordpress_rds_cluster[0].wordpress_rds_address : var.wordpress_db_address
    wordpress_efsid = var.wordpress_efs == true ? module.wordpress_efs[0].wordpress_efsid : var.wordpress_efsid
    wordpress_elastic_ip = var.wordpress_elastic_ip
    wordpress_efs = var.wordpress_efs
    instance_type = var.instance_type
    user_data_file = var.user_data_file
    depends_on = [module.wordpress_rds_cluster,module.wordpress_efs]
}
# Module to create Mysql RDS cluster. Will be skipped if aurora is enabled
module "wordpress_rds_cluster" {
    count = var.wordpress_rds_instance == true ? 1 : 0
    source = "./rds"
    db_subnet_list = [module.wordpress_vpc.private-db-1a,module.wordpress_vpc.private-db-1b,module.wordpress_vpc.private-db-1c,module.wordpress_vpc.private-db-1d] 
    wordpress_rds_sg = module.wordpress_vpc.wordpress_rds_sg
    rds_instance_class = var.rds_instance_class
    rds_db_engine = var.rds_db_engine
    rds_db_engine_version = var.rds_db_engine_version
    rds_db_name = var.wordpress_db_name
    rds_db_user = var.wordpress_db_user
    rds_db_password = var.wordpress_db_password
    availability_zone = var.multi_az == false ? slice(data.aws_availability_zones.available.names,0,1)[0] : null
    multi_az = var.multi_az
    rds_storage_type = var.rds_storage_type
    rds_allocated_storage = var.rds_allocated_storage
}
#Module to create EFS file system
module "wordpress_efs" {
    count = var.wordpress_efs == true ? 1 : 0
    source = "./efs"
    app_subnetid_list = [module.wordpress_vpc.private-app-1a,module.wordpress_vpc.private-app-1b,module.wordpress_vpc.private-app-1c]
    wordpress_efs_sg = module.wordpress_vpc.wordpress_efs_sg
    efs_performance_mode = var.efs_performance_mode 
    efs_throughput_mode = var.efs_throughput_mode
    efs_encryption = var.efs_encryption 
}
#Module to create Auto Scaling Group and Application Load balancer
module "wordpress_asg" {
    count =  var.wordpress_autoscaling == true ? 1 : 0
    source = "./asg"
    vpc_id = module.wordpress_vpc.vpcid
    public_subnet_list = [module.wordpress_vpc.public-web-1a,module.wordpress_vpc.public-web-1b,module.wordpress_vpc.public-web-1c]
    wordpress_public_sg = module.wordpress_vpc.wordpress_public_sg
    wordpress_db_name = var.wordpress_db_name
    wordpress_db_user = var.wordpress_db_user
    wordpress_db_password = var.wordpress_db_password
    wordpress_db_address = var.wordpress_rds_instance == true ? module.wordpress_rds_cluster[0].wordpress_rds_address : module.wordpress_aurora[0].aurora_endpoint
    wordpress_efsid = var.wordpress_efs == true ? module.wordpress_efs[0].wordpress_efsid : var.wordpress_efsid
    asg_desired_capacity = var.asg_desired_capacity
    asg_max_size = var.asg_max_size
    asg_min_size = var.asg_min_size
    asg_health_check_type = var.asg_health_check_type
    cpu_scaleout_threshold = var.cpu_scaleout_threshold
    cpu_scalein_threshold = var.cpu_scalein_threshold
    aws_region = var.aws_region
    instance_type = var.instance_type
    user_data_file = var.user_data_file
    depends_on = [module.wordpress_rds_cluster,module.wordpress_efs,module.wordpress_aurora]
}
#Module to create aurora cluster
module "wordpress_aurora" {
    count = var.wordpress_aurora == true ? 1 : 0
    source = "./aurora"
    aurora_az_list = local.az_list
    aurora_db_name = var.wordpress_db_name
    aurora_db_user = var.wordpress_db_user
    aurora_db_password = var.wordpress_db_password
    db_subnet_list = [module.wordpress_vpc.private-db-1a,module.wordpress_vpc.private-db-1b,module.wordpress_vpc.private-db-1c] 
    aurora_instance_class = var.aurora_instance_class
    aurora_db_engine = var.aurora_db_engine
    aurora_db_engine_version = var.aurora_db_engine_version
    aurora_security_group = module.wordpress_vpc.wordpress_rds_sg
}