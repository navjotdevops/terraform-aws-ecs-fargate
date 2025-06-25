# Terraform AWS ECS Fargate Module

A comprehensive and flexible Terraform module for deploying AWS ECS Fargate clusters with dynamic support for services, target groups, and CloudMap service discovery.

## 🏗️ Module Structure

The module is organized into separate files for better maintainability:

```
├── cluster.tf           # ECS Cluster and capacity providers
├── services.tf          # ECS Services configuration
├── task_definitions.tf  # ECS Task definitions
├── target_groups.tf     # Load balancer target groups
├── service_discovery.tf # CloudMap service discovery
├── cloudwatch.tf        # CloudWatch log groups
├── locals.tf           # Local values and data transformations
├── data.tf             # Data sources
├── variables.tf        # Input variables
├── outputs.tf          # Output values
├── versions.tf         # Provider requirements
└── examples/           # Usage examples
```

## ✨ Features

- ✅ **ECS Cluster Management** - Create and configure ECS clusters with custom settings
- ✅ **Fargate Services** - Deploy containerized applications using AWS Fargate
- ✅ **Dynamic Target Groups** - Flexible load balancer target group configuration
- ✅ **CloudMap Integration** - Service discovery with AWS Cloud Map
- ✅ **Auto Scaling Support** - Built-in capacity provider strategies
- ✅ **CloudWatch Logging** - Centralized logging with configurable retention
- ✅ **Health Checks** - Container and load balancer health monitoring
- ✅ **Security** - IAM roles and security group integration
- ✅ **Multi-Service** - Deploy multiple services in a single cluster

## 🚀 Quick Start

### 1. Basic Web Application

```hcl
module "ecs_fargate" {
  source = "navjotdevops/ecs-fargate/aws"

  cluster_name = "my-web-app"

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

### 2. Microservices with Service Discovery

```hcl
module "ecs_fargate" {
  source = "navjotdevops/ecs-fargate/aws"

  cluster_name = "microservices"

  # Enable service discovery
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
        }
      ]

      secrets = [
        {
          name       = "DB_PASSWORD"
          value_from = "arn:aws:secretsmanager:us-west-2:123456789012:secret:db-password"
        }
      ]

      # Load balancer integration
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
          }
        }
      }

      # Service discovery
      service_discovery = {
        container_port             = 8080
        dns_ttl                   = 60
        health_check_grace_period = 120
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

      # Only service discovery, no load balancer
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

## 📋 Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 5.0 |

## 🔧 Usage Patterns

### Service Configuration

Each service supports flexible configuration:

```hcl
services = {
  service_name = {
    # Required
    image              = "nginx:latest"
    cpu                = 256
    memory             = 512
    desired_count      = 2
    subnet_ids         = ["subnet-12345"]
    security_group_ids = ["sg-12345"]
    execution_role_arn = "arn:aws:iam::123456789012:role/ecsTaskExecutionRole"
    container_ports    = [
      {
        container_port = 80
        protocol       = "tcp"
      }
    ]

    # Optional
    task_role_arn         = "arn:aws:iam::123456789012:role/ecsTaskRole"
    assign_public_ip      = false
    log_retention_days    = 7
    log_kms_key_id       = "arn:aws:kms:us-west-2:123456789012:key/12345"

    environment_variables = [
      {
        name  = "ENV"
        value = "production"
      }
    ]

    secrets = [
      {
        name       = "API_KEY"
        value_from = "arn:aws:secretsmanager:us-west-2:123456789012:secret:api-key"
      }
    ]

    health_check = {
      command      = ["CMD-SHELL", "curl -f http://localhost/health || exit 1"]
      interval     = 30
      timeout      = 5
      retries      = 3
      start_period = 60
    }

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

    service_discovery = {
      container_port             = 80
      dns_ttl                   = 60
      health_check_grace_period = 60
    }

    deployment_configuration = {
      maximum_percent         = 200
      minimum_healthy_percent = 100
    }
  }
}
```

### Target Groups

Target groups are dynamically created for load balancer integration:

```hcl
target_groups = {
  web = {
    port           = 80
    protocol       = "HTTP"
    vpc_id         = "vpc-12345"
    container_port = 80
    health_check = {
      enabled             = true
      healthy_threshold   = 2
      unhealthy_threshold = 2
      timeout             = 5
      interval            = 30
      matcher             = "200"
      path                = "/health"
      port                = "traffic-port"
      protocol            = "HTTP"
    }
  }
  
  api = {
    port           = 8080
    protocol       = "HTTP"
    vpc_id         = "vpc-12345"
    container_port = 8080
    health_check = {
      path = "/api/health"
    }
  }
}
```

### Service Discovery

Enable CloudMap service discovery for service-to-service communication:

```hcl
# Namespace configuration
service_discovery_namespace = {
  name   = "myapp.local"
  vpc_id = "vpc-12345"
}

# Per-service configuration
service_discovery = {
  container_port             = 8080
  dns_ttl                   = 60
  health_check_grace_period = 60
}
```

Services will be accessible at: `service_name.myapp.local`

## 📊 Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster_name | Name of the ECS cluster | `string` | n/a | yes |
| services | Map of ECS services to create | `map(object)` | n/a | yes |
| cluster_settings | List of cluster settings | `list(object)` | `[{name="containerInsights", value="enabled"}]` | no |
| capacity_providers | List of capacity providers | `list(string)` | `["FARGATE", "FARGATE_SPOT"]` | no |
| service_discovery_namespace | Service discovery namespace | `object` | `null` | no |
| tags | Tags to assign to resources | `map(string)` | `{}` | no |

## 📤 Outputs

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

## 📚 Examples

Complete working examples are available in the `examples/` directory:

- **[Basic Web App](examples/basic-web-app/)** - Simple NGINX deployment with ALB
- **[Microservices](examples/microservices/)** - Multi-service setup with service discovery
- **[Multi-Environment](examples/multi-environment/)** - Environment-specific configurations

## 🔍 Best Practices

### 1. Resource Sizing

```hcl
# Small workload
cpu    = 256
memory = 512

# Medium workload  
cpu    = 512
memory = 1024

# Large workload
cpu    = 1024
memory = 2048
```

### 2. Health Checks

```hcl
# Container health check
health_check = {
  command      = ["CMD-SHELL", "curl -f http://localhost/health || exit 1"]
  interval     = 30
  timeout      = 5
  retries      = 3
  start_period = 60
}

# Load balancer health check
health_check = {
  path                = "/health"
  healthy_threshold   = 2
  unhealthy_threshold = 3
  timeout             = 10
  interval            = 30
  matcher             = "200"
}
```

### 3. Security

```hcl
# Use least privilege IAM roles
execution_role_arn = aws_iam_role.ecs_execution_role.arn
task_role_arn     = aws_iam_role.ecs_task_role.arn

# Store secrets securely
secrets = [
  {
    name       = "DB_PASSWORD"
    value_from = "arn:aws:secretsmanager:region:account:secret:name"
  }
]
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Authors

- **[navjotdevops](https://github.com/navjotdevops)** - *Initial work*

## 📝 Changelog

See [CHANGELOG.md](CHANGELOG.md) for a list of changes and version history.

## 🆘 Support

If you have questions or need help:

1. Check the [examples](examples/) directory
2. Review the [documentation](#-inputs)
3. Open an [issue](https://github.com/navjotdevops/terraform-aws-ecs-fargate/issues)

---

⭐ **Star this repository if it helped you!**