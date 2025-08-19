output "public_dns" {
  value       = aws_instance.jumphost.public_dns
  description = "The FQDN of the bastion host"
}

output "security_group_id" {
  value       = aws_security_group.ssh.id
  description = "The security group ID of the bastion host"
}

output "fqdn" {
  value       = var.fqdn
  description = "The fully qualified domain name (FQDN) for the bastion host"
}
