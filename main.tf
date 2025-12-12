# ------------------------------------------------------------------------------
# Local Variables
# ------------------------------------------------------------------------------
locals {
  name_prefix = "${var.project_name}-${var.environment}"

  # Use provided image or fallback to ECR URL with 'latest' tag
  # After first apply, update terraform.tfvars with real ECR URL
  container_image = var.container_image != "" ? var.container_image : "${module.ecr.repository_url}:latest"
}

# ------------------------------------------------------------------------------
# VPC & Networking
# ------------------------------------------------------------------------------
module "vpc" {
  source = "./modules/vpc"

  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  tags                 = var.common_tags
}

# ------------------------------------------------------------------------------
# ECR Repository
# ------------------------------------------------------------------------------
module "ecr" {
  source = "./modules/ecr"

  project_name = var.project_name
  environment  = var.environment
  tags         = var.common_tags
}

# ------------------------------------------------------------------------------
# CloudWatch Logs
# ------------------------------------------------------------------------------
module "cloudwatch" {
  source = "./modules/cloudwatch"

  log_group_name = "/ecs/${local.name_prefix}"
  retention_days = 7
  tags           = var.common_tags
}

# ------------------------------------------------------------------------------
# IAM Roles
# ------------------------------------------------------------------------------
module "iam" {
  source = "./modules/iam"

  project_name = var.project_name
  environment  = var.environment
  tags         = var.common_tags
}

# ------------------------------------------------------------------------------
# Application Load Balancer
# ------------------------------------------------------------------------------
module "alb" {
  source = "./modules/alb"

  project_name      = var.project_name
  environment       = var.environment
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  security_group_id = module.vpc.alb_security_group_id
  target_port       = var.container_port
  health_check_path = "/"
  tags              = var.common_tags
}

# ------------------------------------------------------------------------------
# ECS Cluster & Service
# ------------------------------------------------------------------------------
module "ecs" {
  source = "./modules/ecs"

  project_name            = var.project_name
  environment             = var.environment
  vpc_id                  = module.vpc.vpc_id
  private_subnet_ids      = module.vpc.private_subnet_ids
  security_group_id       = module.vpc.ecs_tasks_security_group_id
  container_image         = local.container_image
  container_port          = var.container_port
  task_cpu                = var.task_cpu
  task_memory             = var.task_memory
  log_group_name          = module.cloudwatch.log_group_name
  aws_region              = var.aws_region
  task_execution_role_arn = module.iam.task_execution_role_arn
  desired_count           = var.desired_count
  max_count               = var.max_count
  target_group_arn        = module.alb.target_group_arn
  tags                    = var.common_tags

  depends_on = [module.alb]
}