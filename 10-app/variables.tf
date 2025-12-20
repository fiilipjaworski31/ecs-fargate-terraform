# ------------------------------------------------------------------------------
# Project Configuration
# ------------------------------------------------------------------------------
variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "ecs-hello"
}

variable "environment" {
  description = "Environment name (dev/prod)"
  type        = string
}

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "eu-central-1"
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}

# ------------------------------------------------------------------------------
# Network Configuration
# ------------------------------------------------------------------------------
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "availability_zones" {
  description = "Availability zones for subnets"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
}

# ------------------------------------------------------------------------------
# ECS Configuration
# ------------------------------------------------------------------------------
variable "container_port" {
  description = "Port exposed by container"
  type        = number
  default     = 8080
}

variable "task_cpu" {
  description = "CPU units for ECS task"
  type        = string
  default     = "256"
}

variable "task_memory" {
  description = "Memory for ECS task (MB)"
  type        = string
  default     = "512"
}

variable "desired_count" {
  description = "Desired number of ECS tasks"
  type        = number
  default     = 1
}

variable "max_count" {
  description = "Maximum number of ECS tasks"
  type        = number
  default     = 3
}

# ------------------------------------------------------------------------------
# Container Configuration
# ------------------------------------------------------------------------------
variable "container_image" {
  description = "Docker image URL - leave empty to auto-generate from ECR repository URL"
  type        = string
  default     = ""
}