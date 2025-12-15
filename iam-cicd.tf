# ------------------------------------------------------------------------------
# Data source - AWS Account ID
# ------------------------------------------------------------------------------
data "aws_caller_identity" "current" {}

# ------------------------------------------------------------------------------
# IAM Role - Terraform Plan (Read-Only)
# ------------------------------------------------------------------------------
resource "aws_iam_role" "github_actions_plan" {
  name = "${var.project_name}-${var.environment}-github-plan"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = data.aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:fiilipjaworski31/ecs-fargate-terraform:*"
          }
        }
      }
    ]
  })

  tags = var.common_tags
}

# ------------------------------------------------------------------------------
# IAM Role - Terraform Apply (Full Permissions)
# ------------------------------------------------------------------------------
resource "aws_iam_role" "github_actions_apply" {
  name = "${var.project_name}-${var.environment}-github-apply"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = data.aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:fiilipjaworski31/ecs-fargate-terraform:*"
          }
        }
      }
    ]
  })

  tags = var.common_tags
}

# ------------------------------------------------------------------------------
# IAM Policy - Plan Role (Read-Only)
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
          "arn:aws:s3:::terraform-state-ecs-fargate-*",
          "arn:aws:s3:::terraform-state-ecs-fargate-*/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem"
        ]
        Resource = "arn:aws:dynamodb:*:${data.aws_caller_identity.current.account_id}:table/terraform-state-lock-*"
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
          "iam:ListAttachedRolePolicies",
          "iam:ListRolePolicies",
          "application-autoscaling:Describe*",
          "cloudwatch:Describe*",
          "cloudwatch:List*"
        ]
        Resource = "*"
      }
    ]
  })
}

# ------------------------------------------------------------------------------
# IAM Policy - Apply Role (Full Permissions)
# ------------------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "apply_admin" {
  role       = aws_iam_role.github_actions_apply.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}