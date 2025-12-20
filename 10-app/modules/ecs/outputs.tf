# ------------------------------------------------------------------------------
# Cluster Outputs
# ------------------------------------------------------------------------------
output "cluster_id" {
  description = "ID of ECS cluster"
  value       = aws_ecs_cluster.main.id
}

output "cluster_name" {
  description = "Name of ECS cluster"
  value       = aws_ecs_cluster.main.name
}

output "cluster_arn" {
  description = "ARN of ECS cluster"
  value       = aws_ecs_cluster.main.arn
}

# ------------------------------------------------------------------------------
# Service Outputs
# ------------------------------------------------------------------------------
output "service_id" {
  description = "ID of ECS service"
  value       = aws_ecs_service.main.id
}

output "service_name" {
  description = "Name of ECS service"
  value       = aws_ecs_service.main.name
}

# ------------------------------------------------------------------------------
# Task Definition Outputs
# ------------------------------------------------------------------------------
output "task_definition_arn" {
  description = "ARN of task definition"
  value       = aws_ecs_task_definition.main.arn
}