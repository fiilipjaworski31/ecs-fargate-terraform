# ------------------------------------------------------------------------------
# Project Configuration
# ------------------------------------------------------------------------------
variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

# ------------------------------------------------------------------------------
# Network Configuration
# ------------------------------------------------------------------------------
variable "vpc_id" {
  description = "ID of VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "IDs of private subnets for ECS tasks"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group ID for ECS tasks"
  type        = string
}

# ------------------------------------------------------------------------------
# Container Configuration
# ------------------------------------------------------------------------------
variable "container_image" {
  description = "Docker image URL - uses placeholder until real image is pushed to ECR"
  type        = string
}
variable "container_port" {
  description = "Port exposed by container"
  type        = number
}

variable "task_cpu" {
  description = "CPU units for task"
  type        = string
}

variable "task_memory" {
  description = "Memory for task in MB"
  type        = string
}

# ------------------------------------------------------------------------------
# Logging Configuration
# ------------------------------------------------------------------------------
variable "log_group_name" {
  description = "CloudWatch log group name"
  type        = string
}

variable "aws_region" {
  description = "AWS region for logs"
  type        = string
}

# ------------------------------------------------------------------------------
# IAM Configuration
# ------------------------------------------------------------------------------
variable "task_execution_role_arn" {
  description = "ARN of task execution role"
  type        = string
}

# ------------------------------------------------------------------------------
# Service Configuration
# ------------------------------------------------------------------------------
variable "desired_count" {
  description = "Desired number of tasks"
  type        = number
}

variable "max_count" {
  description = "Maximum number of tasks"
  type        = number
}

variable "target_group_arn" {
  description = "ARN of ALB target group"
  type        = string
}

variable "health_check_grace_period" {
  description = "Health check grace period in seconds"
  type        = number
  default     = 60
}

# ------------------------------------------------------------------------------
# Tags
# ------------------------------------------------------------------------------
variable "tags" {
  description = "Tags for ECS resources"
  type        = map(string)
  default     = {}
}

variable "enable_container_insights" {
  description = "Enable CloudWatch Container Insights"
  type        = bool
  default     = true
}

variable "enable_auto_scaling" {
  description = "Enable auto scaling for ECS service"
  type        = bool
  default     = true
}

variable "cpu_target_value" {
  description = "Target CPU utilization for auto scaling"
  type        = number
  default     = 70
}

variable "scale_in_cooldown" {
  description = "Cooldown period for scale in (seconds)"
  type        = number
  default     = 300
}

variable "scale_out_cooldown" {
  description = "Cooldown period for scale out (seconds)"
  type        = number
  default     = 60
}