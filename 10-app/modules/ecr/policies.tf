# ------------------------------------------------------------------------------
# ECR Lifecycle Policy
# Automatically removes old images to reduce storage costs
# ------------------------------------------------------------------------------
data "aws_iam_policy_document" "lifecycle" {
  statement {
    sid    = "KeepLastNImages"
    effect = "Allow"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "ecr:DescribeImages",
      "ecr:ListImages",
      "ecr:BatchDeleteImage"
    ]
  }
}

resource "aws_ecr_lifecycle_policy" "main" {
  count = var.lifecycle_policy_enabled ? 1 : 0

  repository = aws_ecr_repository.main.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep last ${var.lifecycle_policy_count} images"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = var.lifecycle_policy_count
      }
      action = {
        type = "expire"
      }
    }]
  })
}