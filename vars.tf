variable "aws_region" {
  description = "The AWS region where resources will be created"
  type        = string
  default     = "eu-central-1"
}

variable "route53_zone_id" {
  description = "The Route 53 zone ID"
  type        = string
}

variable "fqdn" {
  description = "The fully qualified domain name (FQDN) for the bastion host"
  type        = string
}

variable "bastion_default_public_key" {
  description = "The default public key for the bastion host"
  type        = string
}

variable "ecs_clusters" {
  type = map(object({}))
  description = "Map of ECS cluster names to their configurations"
}