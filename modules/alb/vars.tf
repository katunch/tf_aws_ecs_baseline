variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "name" {
  description = "ALB Name"
  type        = string
  default     = "default-alb"
}

variable "public_subnet_ids" {
  description = "Public Subnets IDs"
  type        = list(string)
}

variable "default_ssl_certificate_arn" {
  description = "Default SSL Certificate ARN"
  type        = string
}

variable "default_redirection_fqdn" {
  description = "Default Redirection FQDN"
  type        = string
  default     = "www.software-brauerei.ch"
}