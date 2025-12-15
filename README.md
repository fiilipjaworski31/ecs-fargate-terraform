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

## Auto-Scaling Configuration (Part 3)

ECS Service automatically scales based on CPU utilization:
- **Minimum tasks**: 1
- **Maximum tasks**: 3
- **Scale-out trigger**: Average CPU > 50%
- **Scale-in trigger**: Average CPU < 25% for 5 consecutive minutes (300 seconds)
- **Cooldown**: 60s scale-out, 300s scale-in

### Testing Auto-Scaling

Generate CPU load to trigger scale-out:
```bash
# Generate load with curl loop
for i in {1..180000}; do
  curl -s http://$(terraform output -raw alb_dns_name)/ > /dev/null &
  if [ $((i % 100)) -eq 0 ]; then
    sleep 0.33
  fi
done

# Monitor scaling in another terminal
while true; do
  echo "=== $(date) ==="
  aws ecs describe-services \
    --cluster $(terraform output -raw ecs_cluster_name) \
    --services $(terraform output -raw ecs_service_name) \
    --region eu-central-1 \
    --query 'services[0].{desired:desiredCount,running:runningCount}' \
    --output table
  sleep 10
done
```

Expected behavior:
1. Initial state: 1 task running
2. After 1-2 minutes of high CPU: desired count increases to 2
3. If CPU remains high: may scale to 3 tasks
4. After stopping load and 5 minutes below 25%: scales back to 1

## CI/CD Pipeline (Part 3)

### Pipeline Architecture

GitHub Actions workflow with OIDC authentication (no AWS credentials in repo):

**Pipeline Stages:**
1. **Init & Validate** (automatic on push)
   - `terraform init`
   - `terraform fmt -check`
   - `terraform validate`
   - `tflint`

2. **Plan** (automatic after Init)
   - `terraform plan`
   - Saves plan as artifact for Apply stage
   - Uses read-only IAM role

3. **Docker Build & Push** (automatic on main branch)
   - Builds Docker image from `/app`
   - Pushes to ECR with tags: `latest` and `${github.sha}`
   - Only runs if ECR repository exists

4. **Apply** (manual trigger only)
   - Uses saved plan artifact from Plan stage
   - Applies infrastructure changes
   - Uses full-permission IAM role

### Pipeline Authentication

Uses OpenID Connect (OIDC) with two IAM roles for security:

**Plan Role** (`ecs-hello-dev-github-plan`):
- Read-only access to Terraform state (S3)
- DynamoDB lock operations
- Describe/List permissions for AWS resources
- Cannot create, modify, or delete infrastructure

**Apply Role** (`ecs-hello-dev-github-apply`):
- Full AdministratorAccess for infrastructure management
- ECR push permissions for Docker images
- Only used for Apply stage (manual trigger)

### Running the Pipeline

**Automatic triggers:**
```bash
# Push to main or feature branch triggers Init + Plan
git push origin main

# Merge to main also triggers Docker build
```

**Manual Apply:**
1. Go to GitHub Actions tab
2. Select "Terraform CI/CD" workflow
3. Click "Run workflow"
4. Select branch: `main`
5. Select action: `apply`
6. Click "Run workflow"

### GitHub Secrets Required

Configure in repository Settings → Secrets and variables → Actions:
- `AWS_ROLE_PLAN_ARN`: ARN of plan IAM role
- `AWS_ROLE_APPLY_ARN`: ARN of apply IAM role

Get ARNs from Terraform outputs:
```bash
terraform output github_actions_plan_role_arn
terraform output github_actions_apply_role_arn
```

## CloudWatch Logging (Part 3)

- **Log Group**: `/ecs/ecs-hello-dev`
- **Retention**: 14 days (updated from 7 days)
- **Stream Prefix**: `ecs`

### Viewing Logs
```bash
# Tail logs in real-time
aws logs tail /ecs/ecs-hello-dev --follow

# Search for errors
aws logs filter-log-events \
  --log-group-name /ecs/ecs-hello-dev \
  --filter-pattern "ERROR"

# Get logs from specific time range
aws logs filter-log-events \
  --log-group-name /ecs/ecs-hello-dev \
  --start-time $(date -d '1 hour ago' +%s)000 \
  --end-time $(date +%s)000
```

## State Locking & Concurrency

Terraform state uses DynamoDB locking to prevent concurrent modifications:
- **Lock Table**: `terraform-state-lock-ecs`
- Multiple engineers cannot apply simultaneously
- Pipeline jobs respect the same lock
- Prevents state corruption and race conditions

If a lock is stuck (job was killed), force unlock:
```bash
terraform force-unlock <LOCK_ID>
```

## Best Practices Implemented (Updated)

1. **Modular Design**: Each AWS service in separate module for reusability
2. **Remote State**: S3 backend with DynamoDB locking prevents concurrent changes
3. **Tagging**: Consistent tagging via provider default_tags (DRY principle)
4. **Parameterization**: Zero hardcoded values - all configurable via variables
5. **Security**: Private subnets for ECS, security groups with least-privilege, OIDC for CI/CD
6. **High Availability**: Multi-AZ deployment for resilience
7. **Auto Scaling**: CPU-based scaling (min 1, max 3 tasks)
8. **Observability**: CloudWatch Logs with 14-day retention, Container Insights enabled
9. **Lifecycle Management**: create_before_destroy for zero-downtime updates
10. **CI/CD**: Automated pipeline with OIDC authentication and least-privilege IAM roles
11. **Plan Artifacts**: Exact plan is applied to prevent drift
12. **Docker Automation**: Image build and push fully automated in pipeline

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