# Terraform AWS ECS Fargate Module

A comprehensive and flexible Terraform module for deploying AWS ECS Fargate clusters with dynamic support for services, target groups, and CloudMap service discovery.

## Features

- ✅ **ECS Cluster Management** - Create and configure ECS clusters with custom settings
- ✅ **Fargate Services** - Deploy containerized applications using AWS Fargate
- ✅ **Dynamic Target Groups** - Flexible load balancer target group configuration
- ✅ **CloudMap Integration** - Service discovery with AWS Cloud Map
- ✅ **Auto Scaling Support** - Built-in capacity provider strategies
- ✅ **CloudWatch Logging** - Centralized logging with configurable retention
- ✅ **Health Checks** - Container and load balancer health monitoring
- ✅ **Security** - IAM roles and security group integration
- ✅ **Multi-Service** - Deploy multiple services in a single cluster

## Usage

### Basic Example

```hcl
module "ecs_fargate" {
  source = "navjotdevops/ecs-fargate/aws"

  cluster_name = "my-app-cluster"

  services = {
    web = {
      image              = "nginx:latest"
      cpu                = 256
      memory             = 512
      desired_count      = 2
      subnet_ids         = ["subnet-12345", "subnet-67890"]
      security_group_ids = ["sg-12345"]
      execution_role_arn = "arn:aws:iam::123456789012:role/ecsTaskExecutionRole"

      container_ports = [
        {
          container_port = 80
          protocol       = "tcp"
        }
      ]

      target_groups = {
        web = {
          port           = 80
          protocol       = "HTTP"
          vpc_id         = "vpc-12345"
          container_port = 80
          health_check = {
            path = "/health"
          }
        }
      }
    }
  }

  tags = {
    Environment = "production"
    Project     = "my-app"
  }
}
```

### Advanced Example with Service Discovery

```hcl
module "ecs_fargate" {
  source = "navjotdevops/ecs-fargate/aws"

  cluster_name = "microservices-cluster"

  # Service Discovery Namespace
  service_discovery_namespace = {
    name   = "microservices.local"
    vpc_id = "vpc-12345"
  }

  services = {
    api = {
      image              = "my-api:v1.0.0"
      cpu                = 512
      memory             = 1024
      desired_count      = 3
      subnet_ids         = ["subnet-12345", "subnet-67890"]
      security_group_ids = ["sg-12345"]
      execution_role_arn = "arn:aws:iam::123456789012:role/ecsTaskExecutionRole"
      task_role_arn     = "arn:aws:iam::123456789012:role/ecsTaskRole"

      container_ports = [
        {
          container_port = 8080
          protocol       = "tcp"
        }
      ]

      environment_variables = [
        {
          name  = "ENV"
          value = "production"
        },
        {
          name  = "LOG_LEVEL"
          value = "info"
        }
      ]

      secrets = [
        {
          name       = "DB_PASSWORD"
          value_from = "arn:aws:secretsmanager:us-west-2:123456789012:secret:db-password"
        }
      ]

      target_groups = {
        api = {
          port           = 8080
          protocol       = "HTTP"
          vpc_id         = "vpc-12345"
          container_port = 8080
          health_check = {
            path                = "/api/health"
            healthy_threshold   = 2
            unhealthy_threshold = 3
            timeout             = 10
            interval            = 30
          }
        }
      }

      service_discovery = {
        container_port             = 8080
        dns_ttl                   = 60
        health_check_grace_period = 120
      }

      health_check = {
        command      = ["CMD-SHELL", "curl -f http://localhost:8080/health || exit 1"]
        interval     = 30
        timeout      = 5
        retries      = 3
        start_period = 60
      }
    }

    worker = {
      image              = "my-worker:v1.0.0"
      cpu                = 256
      memory             = 512
      desired_count      = 2
      subnet_ids         = ["subnet-12345", "subnet-67890"]
      security_group_ids = ["sg-12345"]
      execution_role_arn = "arn:aws:iam::123456789012:role/ecsTaskExecutionRole"

      container_ports = []

      service_discovery = {
        container_port = 9090
        dns_ttl       = 30
      }
    }
  }

  tags = {
    Environment = "production"
    Project     = "microservices"
  }
}
```

## Requirements

| Name | Version |
|------|------|
| terraform | >= 1.0 |
| aws | >= 5.0 |

## Providers

| Name | Version |
|------|------|
| aws | >= 5.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster_name | Name of the ECS cluster | `string` | n/a | yes |
| services | Map of ECS services to create | `map(object)` | n/a | yes |
| cluster_settings | List of cluster settings | `list(object)` | `[{name="containerInsights", value="enabled"}]` | no |
| capacity_providers | List of capacity providers for the cluster | `list(string)` | `["FARGATE", "FARGATE_SPOT"]` | no |
| service_discovery_namespace | Service discovery namespace configuration | `object` | `null` | no |
| tags | A map of tags to assign to the resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster_id | ID of the ECS cluster |
| cluster_arn | ARN of the ECS cluster |
| cluster_name | Name of the ECS cluster |
| service_arns | ARNs of the ECS services |
| service_names | Names of the ECS services |
| task_definition_arns | ARNs of the task definitions |
| target_group_arns | ARNs of the target groups |
| cloudwatch_log_groups | Names of the CloudWatch log groups |
| service_discovery_service_arns | ARNs of the service discovery services |
| service_discovery_namespace_id | ID of the service discovery namespace |

## Service Configuration

Each service in the `services` map supports the following configuration:

### Required Parameters
- `image` - Docker image to deploy
- `cpu` - CPU units (256, 512, 1024, 2048, 4096)
- `memory` - Memory in MB
- `desired_count` - Number of tasks to run
- `subnet_ids` - List of subnet IDs
- `security_group_ids` - List of security group IDs
- `execution_role_arn` - ECS task execution role ARN
- `container_ports` - List of container port configurations

### Optional Parameters
- `task_role_arn` - ECS task role ARN
- `assign_public_ip` - Assign public IP (default: false)
- `log_retention_days` - CloudWatch log retention (default: 7)
- `environment_variables` - Environment variables
- `secrets` - Secrets from AWS Secrets Manager/Parameter Store
- `health_check` - Container health check configuration
- `target_groups` - Load balancer target groups
- `service_discovery` - CloudMap service discovery
- `deployment_configuration` - Deployment settings

## Target Groups

Target groups are dynamically created based on the `target_groups` configuration in each service:

```hcl
target_groups = {
  web = {
    port           = 80
    protocol       = "HTTP"
    vpc_id         = "vpc-12345"
    container_port = 80
    health_check = {
      path                = "/health"
      healthy_threshold   = 2
      unhealthy_threshold = 2
      timeout             = 5
      interval            = 30
      matcher             = "200"
    }
  }
}
```

## Service Discovery

Enable service discovery by configuring the namespace and service discovery settings:

```hcl
service_discovery_namespace = {
  name   = "myapp.local"
  vpc_id = "vpc-12345"
}

# In service configuration
service_discovery = {
  container_port             = 8080
  dns_ttl                   = 60
  health_check_grace_period = 60
}
```

## Examples

See the `examples/` directory for complete working examples:

- [Basic Web Application](examples/basic-web-app/)
- [Microservices with Service Discovery](examples/microservices/)
- [Multi-Environment Setup](examples/multi-environment/)

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Authors

Maintained by [navjotdevops](https://github.com/navjotdevops)

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for release history.