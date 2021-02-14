output "wordpress_public_ip" {
    value = var.wordpress_elastic_ip == true ? aws_eip.eip[0].public_ip : aws_instance.wordpress.public_ip
}