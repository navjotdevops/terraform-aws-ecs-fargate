# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-06-25

### Added
- Initial release of the Terraform AWS ECS Fargate module
- ECS Cluster creation and management
- Fargate service deployment with dynamic configuration
- Dynamic target group creation and management
- CloudMap service discovery integration
- CloudWatch logging with configurable retention
- Container health checks
- Load balancer health checks
- Support for environment variables and secrets
- IAM role integration for task execution and task roles
- Capacity provider strategies (FARGATE and FARGATE_SPOT)
- Container Insights support
- Execute command configuration
- Deployment configuration options
- Comprehensive input validation
- Complete output values for integration
- Detailed documentation and examples

### Features
- **Multi-Service Support**: Deploy multiple services in a single cluster
- **Dynamic Target Groups**: Flexible load balancer integration
- **Service Discovery**: AWS CloudMap integration for service-to-service communication
- **Auto Scaling**: Built-in capacity provider strategies
- **Security**: IAM roles and security group integration
- **Monitoring**: CloudWatch logging and Container Insights
- **Health Checks**: Both container and load balancer health monitoring
- **Flexibility**: Highly configurable with sensible defaults

### Documentation
- Comprehensive README with usage examples
- Input and output documentation
- Service configuration guide
- Target group configuration guide
- Service discovery setup guide
- Contributing guidelines

### Examples
- Basic web application example
- Microservices with service discovery example
- Multi-environment setup example

## [Unreleased]

### Planned
- Auto Scaling policies integration
- Blue/Green deployment support
- Circuit breaker patterns
- Observability enhancements
- Cost optimization features
- Additional examples and use cases