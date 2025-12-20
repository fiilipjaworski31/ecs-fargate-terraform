output "log_group_name" {
  description = "Name of CloudWatch log group"
  value       = aws_cloudwatch_log_group.main.name
}

output "log_group_arn" {
  description = "ARN of CloudWatch log group"
  value       = aws_cloudwatch_log_group.main.arn
}