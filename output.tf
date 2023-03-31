### These outputs get parsed to the Terminal after "terraform apply" is done 
output "bastion_ip_addr" {
  value = aws_instance.bastion_host.public_ip
}

output "rds_endpoint" {
    value = aws_rds_cluster.RDSWP.endpoint
}

output "ELB_DNS" {
    value = aws_alb.WPelb.dns_name
}

output "DB_Username" {
  value       = var.DBUser
  sensitive   = false
  description = "Database Username"
}

output "DB_Name" {
  value       = var.DBName
  sensitive   = false
  description = "Database Name"
}

output "DB_Password" {
  value       = var.DBPassword
  sensitive   = true
  description = "Database password"
}

### this resource will create a file and write all important variables into it for future access
resource "local_file" "outputs_file" {
  filename = "${path.module}/${formatdate("YYMMDD", timestamp())}_TF_Outputs.txt"
  content  = <<EOT
This file is automatically created after each terraform run. You can refer to this file in the future to check credentials.
This file was created on ${formatdate("DD.MM.YY", timestamp())}.
Bastion IP Address: ${aws_instance.bastion_host.public_ip}
RDS Endpoint: ${aws_rds_cluster.RDSWP.endpoint}
ELB DNS: ${aws_alb.WPelb.dns_name}
DB Username: ${var.DBUser}
DB Name: ${var.DBName}
DB Password: <sensitive>
EOT
}