output "arn" {
  value       = aws_acm_certificate.this.arn
  description = "The ARN of the ACM certificate"
}