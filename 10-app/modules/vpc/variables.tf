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
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "availability_zones" {
  description = "List of availability zones"
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
# Tags
# ------------------------------------------------------------------------------
variable "tags" {
  description = "Tags for VPC resources"
  type        = map(string)
  default     = {}
}

# ------------------------------------------------------------------------------
# VPC Configuration
# ------------------------------------------------------------------------------
variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Enable DNS support in VPC"
  type        = bool
  default     = true
}

variable "map_public_ip_on_launch" {
  description = "Auto-assign public IPs in public subnets"
  type        = bool
  default     = true
}

# ------------------------------------------------------------------------------
# NAT Gateway Configuration
# ------------------------------------------------------------------------------
variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets"
  type        = bool
  default     = true
}

# ------------------------------------------------------------------------------
# Target Group Configuration
# ------------------------------------------------------------------------------
variable "target_group_deregistration_delay" {
  description = "Time to wait before deregistering targets"
  type        = number
  default     = 30
}