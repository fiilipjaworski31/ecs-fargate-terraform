# ------------------------------------------------------------------------------
# S3 & DynamoDB Outputs
# ------------------------------------------------------------------------------
output "terraform_state_bucket" {
  description = "S3 bucket name for Terraform state"
  value       = aws_s3_bucket.terraform_state.id
}

output "terraform_lock_table" {
  description = "DynamoDB table name for state locking"
  value       = aws_dynamodb_table.terraform_lock.id
}

# ------------------------------------------------------------------------------
# IAM Role Outputs
# ------------------------------------------------------------------------------
output "github_actions_plan_role_arn" {
  description = "ARN of GitHub Actions Plan role - add this to GitHub Secrets as AWS_ROLE_PLAN_ARN"
  value       = aws_iam_role.github_actions_plan.arn
}

output "github_actions_apply_role_arn" {
  description = "ARN of GitHub Actions Apply role - add this to GitHub Secrets as AWS_ROLE_APPLY_ARN"
  value       = aws_iam_role.github_actions_apply.arn
}

# ------------------------------------------------------------------------------
# Instructions
# ------------------------------------------------------------------------------
output "next_steps" {
  description = "Instructions for next steps"
  value = <<-EOT
    
    ✅ Bootstrap layer created successfully!
    
    Next steps:
    1. Copy these ARNs to GitHub Secrets:
       - AWS_ROLE_PLAN_ARN: ${aws_iam_role.github_actions_plan.arn}
       - AWS_ROLE_APPLY_ARN: ${aws_iam_role.github_actions_apply.arn}
    
    2. Update 10-app/backend.tf with:
       - bucket: ${aws_s3_bucket.terraform_state.id}
       - dynamodb_table: ${aws_dynamodb_table.terraform_lock.id}
    
    3. Navigate to 10-app/ and run:
       terraform init
       terraform plan
       terraform apply
  EOT
}