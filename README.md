# ECS Fargate Terraform Infrastructure

Infrastructure as Code for deploying a Python Flask "Hello World" application on AWS ECS Fargate.

## Architecture

- **VPC**: Custom VPC with 2 public + 2 private subnets across 2 AZs
- **Networking**: Internet Gateway, NAT Gateway, Route Tables
- **ECR**: Private Docker registry
- **ALB**: Application Load Balancer in public subnets
- **ECS**: Fargate service in private subnets (1-2 tasks)
- **CloudWatch**: Centralized logging
- **IAM**: Task execution role with least-privilege permissions

## Prerequisites

- Terraform >= 1.5.0
- AWS CLI configured
- Docker installed
- AWS credentials with appropriate permissions

## Project Structure
```
.
├── modules/
│   ├── vpc/          # VPC, subnets, NAT, security groups
│   ├── ecr/          # Container registry
│   ├── cloudwatch/   # Log groups
│   ├── iam/          # ECS task execution role
│   ├── alb/          # Application Load Balancer
│   └── ecs/          # ECS cluster, task definition, service
├── environments/
│   ├── dev.tfvars    # Development environment variables
│   └── prod.tfvars   # Production environment variables
├── main.tf           # Root module - orchestrates all modules
├── variables.tf      # Input variable definitions
├── outputs.tf        # Output value definitions
├── versions.tf       # Terraform and provider versions
├── backend.tf        # Remote state configuration
└── terraform.tfvars  # Variable values (gitignored)
```

## Deployment Guide

### Step 1: Create Backend Resources

First, manually create S3 bucket and DynamoDB table for Terraform state:
```bash
# S3 bucket for state
aws s3api create-bucket \
  --bucket terraform-state-ecs-fargate-995419654404 \
  --region eu-central-1 \
  --create-bucket-configuration LocationConstraint=eu-central-1

aws s3api put-bucket-versioning \
  --bucket terraform-state-ecs-fargate-995419654404 \
  --versioning-configuration Status=Enabled

# DynamoDB table for locking
aws dynamodb create-table \
  --table-name terraform-state-lock-ecs \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region eu-central-1
```

### Step 2: Initialize Terraform
```bash
terraform init
```

### Step 3: First Apply (Infrastructure without Application)
```bash
# Review plan
terraform plan

# Apply infrastructure
terraform apply
```

**Note**: ECS will deploy with auto-generated ECR URL. The service will fail initially because no image exists in ECR yet.

### Step 4: Build and Push Docker Image
```bash
# Get ECR repository URL from Terraform output
ECR_URL=$(terraform output -raw ecr_repository_url)

# Navigate to your application directory (contains Dockerfile)
cd ../ECS\ app/

# Authenticate Docker to ECR
aws ecr get-login-password --region eu-central-1 | \
  docker login --username AWS --password-stdin $ECR_URL

# Build image
docker build -t hello-world-app .

# Tag image
docker tag hello-world-app:latest $ECR_URL:latest

# Push to ECR
docker push $ECR_URL:latest
```

### Step 5: Force ECS Service Deployment
```bash
# Return to Terraform directory
cd ../ecs-fargate-terraform/

# Force new deployment to use the pushed image
aws ecs update-service \
  --cluster $(terraform output -raw ecs_cluster_name) \
  --service $(terraform output -raw ecs_service_name) \
  --force-new-deployment \
  --region eu-central-1
```

### Step 6: Verify Deployment
```bash
# Get ALB DNS name
ALB_DNS=$(terraform output -raw alb_dns_name)

# Wait 2-3 minutes for tasks to become healthy, then test
curl http://$ALB_DNS

# Expected response:
# {"message":"Hello world! Today is 2025-12-12"}

# Check CloudWatch logs
aws logs tail $(terraform output -raw log_group_name) --follow
```

## Updating the Application

When you update your Docker image:
```bash
# Build and push new image
docker build -t hello-world-app .
docker tag hello-world-app:latest $ECR_URL:latest
docker push $ECR_URL:latest

# Force ECS to deploy new image
aws ecs update-service \
  --cluster $(terraform output -raw ecs_cluster_name) \
  --service $(terraform output -raw ecs_service_name) \
  --force-new-deployment \
  --region eu-central-1
```

## Using Different Environments
```bash
# Deploy to production
terraform apply -var-file="environments/prod.tfvars"

# Deploy to development
terraform apply -var-file="environments/dev.tfvars"
```

## Cleanup
```bash
# Destroy all infrastructure
terraform destroy

# Delete backend resources (manual)
aws s3 rb s3://terraform-state-ecs-fargate-995419654404 --force
aws dynamodb delete-table --table-name terraform-state-lock-ecs
```

## Best Practices Implemented

1. **Modular Design**: Each AWS service in separate module for reusability
2. **Remote State**: S3 backend with DynamoDB locking prevents concurrent changes
3. **Tagging**: Consistent tagging via provider default_tags (DRY principle)
4. **Parameterization**: Zero hardcoded values - all configurable via variables
5. **Security**: Private subnets for ECS, security groups with least-privilege
6. **High Availability**: Multi-AZ deployment for resilience
7. **Auto Scaling**: CPU-based scaling (min 1, max 2 tasks)
8. **Observability**: CloudWatch Logs with 7-day retention
9. **Lifecycle Management**: create_before_destroy for zero-downtime updates

## Troubleshooting

### ECS Tasks Failing to Start
```bash
# Check task status
aws ecs describe-tasks \
  --cluster $(terraform output -raw ecs_cluster_name) \
  --tasks $(aws ecs list-tasks --cluster $(terraform output -raw ecs_cluster_name) --query 'taskArns[0]' --output text)

# Common issues:
# - Image not found in ECR → Push Docker image
# - Task execution role permissions → Check IAM role
# - Network issues → Verify NAT Gateway and route tables
```

### Target Group Unhealthy
```bash
# Check target health
aws elbv2 describe-target-health \
  --target-group-arn $(terraform output -raw target_group_arn)

# Common issues:
# - Health check path wrong → Should be "/"
# - Security group blocking traffic → Verify SG allows 8080 from ALB
# - Container not listening on 8080 → Check Dockerfile EXPOSE
```

## Cost Estimate

- ECS Fargate (256 CPU, 512 MB): ~$0.013/hour
- Application Load Balancer: ~$0.025/hour
- NAT Gateway: ~$0.045/hour + data transfer
- CloudWatch Logs: Minimal
- **Total**: ~$2-3 USD for 24-hour test deployment

## License

Confidential - DevOps/Cloud Course Material