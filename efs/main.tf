resource "aws_efs_file_system" "wordpress_efs" {
    creation_token = "wordpress_efs"
    performance_mode = "generalPurpose"
    throughput_mode = "bursting" 
}
resource "aws_efs_mount_target" "wordpress_mt" {
    count = length(var.app_subnetid_list)
    file_system_id = aws_efs_file_system.wordpress_efs.id
    subnet_id = var.app_subnetid_list[count.index]
}