# Basic Web Application Example

This example demonstrates how to deploy a simple web application using the ECS Fargate module.

## Architecture

- ECS Fargate cluster with NGINX containers
- Application Load Balancer for traffic distribution
- CloudWatch logging
- Security groups for network isolation

## Usage

1. Update the variables in `terraform.tfvars`:

```hcl
vpc_id             = "vpc-12345678"
private_subnet_ids = ["subnet-12345678", "subnet-87654321"]
public_subnet_ids  = ["subnet-abcdefgh", "subnet-hgfedcba"]
aws_region         = "us-west-2"
```

2. Initialize and apply:

```bash
terraform init
terraform plan
terraform apply
```

3. Access your application using the load balancer DNS name from the output.

## Resources Created

- ECS Cluster
- ECS Service with 2 NGINX tasks
- Application Load Balancer
- Target Group
- Security Groups
- IAM Roles
- CloudWatch Log Groups

## Clean Up

```bash
terraform destroy
```