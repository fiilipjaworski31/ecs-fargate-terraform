variable "project_name" {
  description = "Project name for role naming"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "tags" {
  description = "Tags for IAM role"
  type        = map(string)
  default     = {}
}