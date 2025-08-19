output "public_subnet_ids" {
  value       = data.aws_subnets.public.ids
  description = "The IDs of the public subnets"
}

output "private_subnet_ids" {
  value       = aws_subnet.private[*].id
  description = "List of all private subnet IDs"
}

output "private_subnet_cidr_blocks" {
  value       = aws_subnet.private[*].cidr_block
  description = "List of all private subnet CIDR blocks"
}

output "default_security_group_id" {
  value       = aws_default_security_group.default.id
  description = "The ID of the default security group"
}

output "private_route_table_ids" {
  value       = aws_route_table.private[*].id
  description = "List of all private route table IDs"
}
