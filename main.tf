data "aws_availability_zones" "available" {}
module "wordpress-vpc" {
    source = "./vpc"
    vpc_cidr = var.vpc_cidr
    az_list = data.aws_availability_zones.available.names
}
module "wordpress-ec2-instance" {
    source = "./ec2"
    vpc_id = module.wordpress-vpc.vpcid
    public_subnet_id = module.wordpress-vpc.public-web-1a
    wordpress_public_sg = module.wordpress-vpc.wordpress_public_sg
    wordpress_db_name = var.wordpress_db_name
    wordpress_db_user = var.wordpress_db_user
    wordpress_db_password = var.wordpress_db_password
    wordpress_db_address = var.deployment_type != "single_instance" ? module.wordpress-rds-cluster[0].wordpress_rds_address : ""
    deployment_type = var.deployment_type
    depends_on = [module.wordpress-rds-cluster]
}
module "wordpress-rds-cluster" {
    count = var.deployment_type == "rds_single_az" || var.deployment_type == "rds_multi_az" ? 1 : 0
    source = "./rds"
    db_subnet_list = [module.wordpress-vpc.private-db-1a,module.wordpress-vpc.private-db-1b,module.wordpress-vpc.private-db-1c] 
    wordpress_rds_sg = module.wordpress-vpc.wordpress_rds_sg
    rds_db_name = var.wordpress_db_name
    rds_db_user = var.wordpress_db_user
    rds_db_password = var.wordpress_db_password
    deployment_type = var.deployment_type
    
}
module "wordpress_efs" {
    #count = var.deployment_type == "rds_single_az_efs" || var.deployment_type == "rds_multi_az_efs"
    source = "./efs"
    #private-app-1a = module.wordpress-vpc.private-app-1a
    app_subnetid_list = [module.wordpress-vpc.private-app-1a,module.wordpress-vpc.private-app-1b,module.wordpress-vpc.private-app-1c]
}