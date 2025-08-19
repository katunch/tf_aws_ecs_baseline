output "secrity_group_id" {
  value       = aws_security_group.alb.id
  description = "Security Group ID of the ALB"
}

output "dns_name" {
  value       = aws_lb.default.dns_name
  description = "DNS Name of the ALB"
}

output "arn" {
  value       = aws_lb.default.arn
  description = "ARN of the ALB"
}

output "https_listener_arn" {
  value       = aws_lb_listener.https.arn
  description = "ARN of the HTTPS listener"
}

output "zone_id" {
  value       = aws_lb.default.zone_id
  description = "Zone ID of the ALB"
}