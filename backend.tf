terraform {
  backend "s3" {
    bucket         = "terraform-state-ecs-fargate-995419654404"
    key            = "ecs-fargate/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "terraform-state-lock-ecs"
    encrypt        = true
  }
}