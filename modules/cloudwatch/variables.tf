variable "log_group_name" {
  description = "Name of CloudWatch log group"
  type        = string
}

variable "retention_days" {
  description = "Log retention in days"
  type        = number
  default     = 7
}

variable "tags" {
  description = "Tags for CloudWatch log group"
  type        = map(string)
  default     = {}
}