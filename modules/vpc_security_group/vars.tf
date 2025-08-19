variable "name" {
  description = "Name of the security group"
  type        = string
}
variable "description" {
  description = "Description of the security group"
  type        = string
  default     = "Security group from terraform module vpc_security_group"
}
variable "vpc_id" {
  description = "VPC ID where the security group will be created"
  type        = string
}
variable "tags" {
  description = "Tags to assign to the security group"
  type        = map(string)
  default     = {}
}
variable "ingress_rules" {
  description = "List of ingress rules to apply to the security group"
  type = list(object({
    from_port   = number
    to_port     = number
    ip_protocol = string
    cidr_ipv4   = string
  }))
  default = []
}
variable "egress_rules" {
  description = "List of egress rules to apply to the security group"
  type = list(object({
    from_port   = number
    to_port     = number
    ip_protocol = string
    cidr_ipv4   = string
  }))
  default = []
}
