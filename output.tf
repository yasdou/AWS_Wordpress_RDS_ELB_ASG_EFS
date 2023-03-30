output "bastion_ip_addr" {
  value = aws_instance.bastion_host.public_ip
}

output "rds_endpoint" {
    value = aws_rds_cluster.RDSWP.endpoint
}

output "ELB_DNS" {
    value = aws_alb.WPelb.dns_name
}