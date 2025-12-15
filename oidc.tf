# ------------------------------------------------------------------------------
# Use existing GitHub OIDC Provider
# ------------------------------------------------------------------------------
data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}