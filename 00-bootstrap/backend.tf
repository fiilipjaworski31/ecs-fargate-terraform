# IMPORTANT: For first run, comment out this backend configuration
# After creating S3 bucket, uncomment and run 'terraform init -migrate-state'

# terraform {
#   backend "s3" {
#     bucket         = "terraform-state-ecs-fargate-995419654404"
#     key            = "bootstrap/terraform.tfstate"
#     region         = "eu-central-1"
#     dynamodb_table = "terraform-state-lock-ecs"
#     encrypt        = true
#   }
# }