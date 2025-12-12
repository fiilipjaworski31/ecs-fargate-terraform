# ------------------------------------------------------------------------------
# VPC Outputs
# ------------------------------------------------------------------------------
output "vpc_id" {
  description = "ID of VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR block of VPC"
  value       = aws_vpc.main.cidr_block
}

# ------------------------------------------------------------------------------
# Subnet Outputs
# ------------------------------------------------------------------------------
output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = aws_subnet.private[*].id
}

# ------------------------------------------------------------------------------
# Security Group Outputs
# ------------------------------------------------------------------------------
output "alb_security_group_id" {
  description = "ID of ALB security group"
  value       = aws_security_group.alb.id
}

output "ecs_tasks_security_group_id" {
  description = "ID of ECS tasks security group"
  value       = aws_security_group.ecs_tasks.id
}

# ------------------------------------------------------------------------------
# Gateway Outputs
# ------------------------------------------------------------------------------
output "internet_gateway_id" {
  description = "ID of Internet Gateway"
  value       = aws_internet_gateway.main.id
}

output "nat_gateway_id" {
  description = "ID of NAT Gateway (empty if disabled)"
  value       = var.enable_nat_gateway ? aws_nat_gateway.main[0].id : null
}