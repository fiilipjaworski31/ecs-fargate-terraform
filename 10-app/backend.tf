terraform {
  backend "s3" {
    # These values will be output from bootstrap layer
    bucket         = "terraform-state-ecs-fargate-995419654404"
    key            = "application/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "terraform-state-lock-ecs"
    encrypt        = true
  }
}