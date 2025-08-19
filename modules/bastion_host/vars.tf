variable "name" {
  description = "The name of the bastion host"
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID"
  type        = string
}

variable "subnet_id" {
  description = "The subnet ID where to deploy the bastion host"
  type        = string
}

variable "route53_zone_id" {
  description = "The Route 53 zone ID"
  type        = string
}

variable "fqdn" {
  description = "The fully qualified domain name (FQDN) for the bastion host"
  type        = string
}

variable "public_key" {
  description = "The public key to use for SSH access"
  type        = string
}

variable "additional_ssh_users" {
  description = "Additional SSH users to add to the bastion host"
  type = list(object({
    username   = string
    public_key = string
  }))
  default = []
}

variable "additional_user_data" {
  description = "Additional user data to add to the bastion host"
  type        = string
  default     = ""
}