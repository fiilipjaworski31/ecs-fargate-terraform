# ------------------------------------------------------------------------------
# Data source - AWS Account ID
# ------------------------------------------------------------------------------
data "aws_caller_identity" "current" {}

# ... (reszta bez zmian do IAM Policy)

# ------------------------------------------------------------------------------
# IAM Policy - Plan Role (Read-Only) - FIXED
# ------------------------------------------------------------------------------
resource "aws_iam_role_policy" "plan_policy" {
  name = "terraform-plan-permissions"
  role = aws_iam_role.github_actions_plan.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${data.aws_s3_bucket.terraform_state.id}",
          "arn:aws:s3:::${data.aws_s3_bucket.terraform_state.id}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem"
        ]
        Resource = data.aws_dynamodb_table.terraform_lock.arn
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:Describe*",
          "ecs:Describe*",
          "ecs:List*",
          "elasticloadbalancing:Describe*",
          "ecr:Describe*",
          "ecr:List*",
          "logs:Describe*",
          "iam:GetRole",
          "iam:GetRolePolicy",
          "ecr:GetLifecyclePolicy",
          "iam:ListAttachedRolePolicies",
          "logs:ListTagsForResource",
          "iam:ListRolePolicies",
          "application-autoscaling:ListTagsForResource",
          "application-autoscaling:Describe*",
          "cloudwatch:Describe*",
          "cloudwatch:List*"
        ]
        Resource = "*"
      }
    ]
  })
}

# ... (reszta bez zmian)