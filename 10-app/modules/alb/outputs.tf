# ------------------------------------------------------------------------------
# Load Balancer Outputs
# ------------------------------------------------------------------------------
output "alb_id" {
  description = "ID of Application Load Balancer"
  value       = aws_lb.main.id
}

output "alb_arn" {
  description = "ARN of Application Load Balancer"
  value       = aws_lb.main.arn
}

output "dns_name" {
  description = "DNS name of Application Load Balancer"
  value       = aws_lb.main.dns_name
}

output "zone_id" {
  description = "Zone ID of Application Load Balancer"
  value       = aws_lb.main.zone_id
}

# ------------------------------------------------------------------------------
# Target Group Outputs
# ------------------------------------------------------------------------------
output "target_group_arn" {
  description = "ARN of target group"
  value       = aws_lb_target_group.main.arn
}

output "target_group_name" {
  description = "Name of target group"
  value       = aws_lb_target_group.main.name
}

# ------------------------------------------------------------------------------
# Listener Outputs
# ------------------------------------------------------------------------------
output "listener_arn" {
  description = "ARN of HTTP listener"
  value       = aws_lb_listener.http.arn
}