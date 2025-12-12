# ------------------------------------------------------------------------------
# Task Execution Role Trust Policy
# Allows ECS service to assume this role
# ------------------------------------------------------------------------------
data "aws_iam_policy_document" "ecs_task_execution_assume" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}