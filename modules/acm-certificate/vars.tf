variable "route53_zone_id" {
  description = "Route 53 Hosted Zone ID"
  type        = string
}

variable "fqdn" {
  description = "Hosted Zone Name"
  type        = string
}

variable "additional_fqdns" {
  description = "Additional FQDNs"
  type        = list(string)
}
