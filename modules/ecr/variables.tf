variable "project_name" {
  description = "Project name for repository naming"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "image_tag_mutability" {
  description = "Image tag mutability setting"
  type        = string
  default     = "MUTABLE"
}

variable "scan_on_push" {
  description = "Enable image scanning on push"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags for ECR repository"
  type        = map(string)
  default     = {}
}

# ------------------------------------------------------------------------------
# Lifecycle Policy Configuration
# ------------------------------------------------------------------------------
variable "lifecycle_policy_enabled" {
  description = "Enable lifecycle policy for image cleanup"
  type        = bool
  default     = true
}

variable "lifecycle_policy_count" {
  description = "Number of images to keep"
  type        = number
  default     = 10
}

variable "force_delete" {
  description = "Allow deletion of repository with images (use true for dev/test)"
  type        = bool
  default     = false
}