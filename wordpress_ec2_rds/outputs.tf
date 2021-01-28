output "wordpress-url" {
    value = "http://${module.wordpress-ec2-instance.wordpress_public_ip}"
}