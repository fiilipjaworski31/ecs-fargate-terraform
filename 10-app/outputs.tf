# ------------------------------------------------------------------------------
# Application Access
# ------------------------------------------------------------------------------
output "alb_dns_name" {
  description = "DNS name of Application Load Balancer - use this to access the application"
  value       = module.alb.dns_name
}

output "application_url" {
  description = "Full URL to access the application"
  value       = "http://${module.alb.dns_name}"
}

# ------------------------------------------------------------------------------
# VPC Outputs
# ------------------------------------------------------------------------------
output "vpc_id" {
  description = "ID of VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = module.vpc.private_subnet_ids
}

# ------------------------------------------------------------------------------
# ECR Outputs
# ------------------------------------------------------------------------------
output "ecr_repository_url" {
  description = "URL of ECR repository - push your Docker image here"
  value       = module.ecr.repository_url
}

output "ecr_repository_name" {
  description = "Name of ECR repository"
  value       = module.ecr.repository_name
}

# ------------------------------------------------------------------------------
# ECS Outputs
# ------------------------------------------------------------------------------
output "ecs_cluster_name" {
  description = "Name of ECS cluster"
  value       = module.ecs.cluster_name
}

output "ecs_service_name" {
  description = "Name of ECS service"
  value       = module.ecs.service_name
}

# ------------------------------------------------------------------------------
# CloudWatch Outputs
# ------------------------------------------------------------------------------
output "log_group_name" {
  description = "Name of CloudWatch log group"
  value       = module.cloudwatch.log_group_name
}

# ------------------------------------------------------------------------------
# Security Groups
# ------------------------------------------------------------------------------
output "alb_security_group_id" {
  description = "ID of ALB security group"
  value       = module.vpc.alb_security_group_id
}

output "ecs_tasks_security_group_id" {
  description = "ID of ECS tasks security group"
  value       = module.vpc.ecs_tasks_security_group_id
}

# ------------------------------------------------------------------------------
# Load Balancer Resources
# ------------------------------------------------------------------------------
output "target_group_arn" {
  description = "ARN of ALB target group"
  value       = module.alb.target_group_arn
}

output "alb_arn" {
  description = "ARN of Application Load Balancer"
  value       = module.alb.alb_arn
}

# ------------------------------------------------------------------------------
# Information about Bootstrap Layer
# ------------------------------------------------------------------------------
output "bootstrap_layer_info" {
  description = "Information about Bootstrap layer resources"
  value = <<-EOT
    
    IAM roles for CI/CD are managed in the Bootstrap layer (00-bootstrap/)
    
    To view IAM role ARNs, run:
    cd ../00-bootstrap && terraform output
    
    Current backend configuration:
    - S3 Bucket: terraform-state-ecs-fargate-995419654404
    - DynamoDB Table: terraform-state-lock-ecs
    - State Key: application/terraform.tfstate
  EOT
}