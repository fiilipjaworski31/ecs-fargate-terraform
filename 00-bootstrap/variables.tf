variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "ecs-hello"
}

variable "environment" {
  description = "Environment name (dev/prod)"
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "eu-central-1"
}

variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "github_repository" {
  description = "GitHub repository in format: owner/repo"
  type        = string
  default     = "fiilipjaworski31/ecs-fargate-terraform"
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {
    Project     = "ecs-fargate-terraform"
    Environment = "dev"
    ManagedBy   = "Terraform"
    Layer       = "Bootstrap"
  }
}