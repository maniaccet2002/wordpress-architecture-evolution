data "aws_availability_zones" "available" {}
module "wordpress-vpc" {
    source = "./vpc"
    vpc_cidr = var.vpc_cidr
    az_list = data.aws_availability_zones.available.names
}
module "wordpress-ec2-instance" {
    source = "./ec2"
    vpc_id = module.wordpress-vpc.vpcid
    public_subnet_id = module.wordpress-vpc.public-subnet-1a
}