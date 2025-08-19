output "vpc_id" {
  value       = data.aws_vpc.default.id
  description = "The ID of the VPC"
}

output "route53_zone_id" {
  value       = var.route53_zone_id
  description = "The ID of the Route 53 hosted zone"
}

output "ecs_clusters" {
  value = [for cluster in module.ecs_clusters : {
    name = cluster.cluster_name
    arn  = cluster.cluster_arn
  }]
  description = "List of ECS clusters with their names and ARNs"
}

output "lb_dns_name" {
  value       = module.alb.dns_name
  description = "The DNS name of the load balancer"
}

output "lb_https_listener_arn" {
  value       = module.alb.https_listener_arn
  description = "The ARN of the HTTPS listener for the load balancer"
}

output "lb_zone_id" {
  value       = module.alb.zone_id
  description = "The zone ID of the load balancer"
}

output "vpc_public_subnet_ids" {
  value       = module.vpc.public_subnet_ids
  description = "The IDs of the public subnets in the VPC"
}

output "vpc_private_subnet_ids" {
  value       = module.vpc.private_subnet_ids
  description = "The IDs of the private subnets in the VPC"
}

output "vpc_default_security_group_id" {
  value       = module.vpc.default_security_group_id
  description = "The ID of the default security group in the VPC"
}

output "vpc_internet_access_security_group_id" {
  value       = module.internet_access_security_group.id
  description = "The ID of the internet access security group in the VPC"
}

# output "rds_admin_user" {
#   value       = module.rds.rds_admin_username
#   description = "The admin user for the RDS instance"
# }
# output "rds_admin_password" {
#   value       = module.rds.rds_admin_password
#   description = "The admin password for the RDS instance"
#   sensitive   = true
# }
# output "rds_cluster_endpoint" {
#   value       = module.rds.rds_endpoint
#   description = "The endpoint of the RDS cluster"
# }
# output "rds_db_name" {
#   value       = module.rds.db_name
#   description = "The name of the database in the RDS cluster"
# }
# output "rds_security_group_id" {
#   value       = module.rds.rds_security_group_id
#   description = "The security group ID for the RDS instance"
# }
