# Create EFS file system
resource "aws_efs_file_system" "wordpress_efs" {
    creation_token = "wordpress_efs"
    performance_mode = var.efs_performance_mode
    throughput_mode = var.efs_throughput_mode
    encrypted = var.efs_encryption
}
# Mount targets on application layer subnets which creates ENIs on those subnets
resource "aws_efs_mount_target" "wordpress_mt" {
    count = length(var.app_subnetid_list)
    file_system_id = aws_efs_file_system.wordpress_efs.id
    subnet_id = var.app_subnetid_list[count.index]
    security_groups = [ var.wordpress_efs_sg ]
}