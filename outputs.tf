output "wordpress_url" {
    value = var.wordpress_ec2_instance == true ? "http://${module.wordpress_ec2_instance[0].wordpress_public_ip}" : "http://${module.wordpress_asg[0].elb_dns_name}"
}