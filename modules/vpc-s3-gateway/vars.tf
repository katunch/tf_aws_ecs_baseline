variable "name" {
  description = "The name of the VPC endpoint"
  type        = string
}
variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  type        = string
}

variable "route_table_ids" {
  description = "The IDs of the route tables"
  type        = list(string)
}