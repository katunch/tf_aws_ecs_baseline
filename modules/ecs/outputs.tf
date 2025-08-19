output "cluster_name" {
  value       = aws_ecs_cluster.default.name
  description = "The name of the ECS cluster"
}
output "cluster_arn" {
  value       = aws_ecs_cluster.default.arn
  description = "The ARN of the ECS cluster"
}