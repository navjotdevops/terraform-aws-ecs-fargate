# ECS Cluster
resource "aws_ecs_cluster" "this" {
  name = var.cluster_name

  dynamic "setting" {
    for_each = var.cluster_settings
    content {
      name  = setting.value.name
      value = setting.value.value
    }
  }

  dynamic "configuration" {
    for_each = var.cluster_configuration != null ? [var.cluster_configuration] : []
    content {
      dynamic "execute_command_configuration" {
        for_each = configuration.value.execute_command_configuration != null ? [configuration.value.execute_command_configuration] : []
        content {
          kms_key_id = execute_command_configuration.value.kms_key_id
          logging    = execute_command_configuration.value.logging

          dynamic "log_configuration" {
            for_each = execute_command_configuration.value.log_configuration != null ? [execute_command_configuration.value.log_configuration] : []
            content {
              cloud_watch_encryption_enabled = log_configuration.value.cloud_watch_encryption_enabled
              cloud_watch_log_group_name     = log_configuration.value.cloud_watch_log_group_name
              s3_bucket_name                 = log_configuration.value.s3_bucket_name
              s3_bucket_encryption_enabled   = log_configuration.value.s3_bucket_encryption_enabled
              s3_key_prefix                  = log_configuration.value.s3_key_prefix
            }
          }
        }
      }
    }
  }

  tags = var.tags
}

# ECS Cluster Capacity Providers
resource "aws_ecs_cluster_capacity_providers" "this" {
  count = length(var.capacity_providers) > 0 ? 1 : 0

  cluster_name       = aws_ecs_cluster.this.name
  capacity_providers = var.capacity_providers

  dynamic "default_capacity_provider_strategy" {
    for_each = var.default_capacity_provider_strategy
    content {
      capacity_provider = default_capacity_provider_strategy.value.capacity_provider
      weight           = default_capacity_provider_strategy.value.weight
      base             = default_capacity_provider_strategy.value.base
    }
  }
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "this" {
  for_each = var.services

  name              = "/ecs/${var.cluster_name}/${each.key}"
  retention_in_days = each.value.log_retention_days
  kms_key_id        = each.value.log_kms_key_id

  tags = var.tags
}

# Task Definition
resource "aws_ecs_task_definition" "this" {
  for_each = var.services

  family                   = "${var.cluster_name}-${each.key}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = each.value.cpu
  memory                   = each.value.memory
  execution_role_arn       = each.value.execution_role_arn
  task_role_arn           = each.value.task_role_arn

  container_definitions = jsonencode([
    {
      name      = each.key
      image     = each.value.image
      essential = true

      portMappings = [
        for port in each.value.container_ports : {
          containerPort = port.container_port
          hostPort      = port.host_port
          protocol      = port.protocol
        }
      ]

      environment = [
        for env in each.value.environment_variables : {
          name  = env.name
          value = env.value
        }
      ]

      secrets = [
        for secret in each.value.secrets : {
          name      = secret.name
          valueFrom = secret.value_from
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.this[each.key].name
          "awslogs-region"        = data.aws_region.current.name
          "awslogs-stream-prefix" = "ecs"
        }
      }

      healthCheck = each.value.health_check != null ? {
        command     = each.value.health_check.command
        interval    = each.value.health_check.interval
        timeout     = each.value.health_check.timeout
        retries     = each.value.health_check.retries
        startPeriod = each.value.health_check.start_period
      } : null
    }
  ])

  tags = var.tags
}

# ECS Service
resource "aws_ecs_service" "this" {
  for_each = var.services

  name            = each.key
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this[each.key].arn
  desired_count   = each.value.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = each.value.subnet_ids
    security_groups  = each.value.security_group_ids
    assign_public_ip = each.value.assign_public_ip
  }

  dynamic "load_balancer" {
    for_each = each.value.target_groups
    content {
      target_group_arn = aws_lb_target_group.this["${each.key}-${load_balancer.key}"].arn
      container_name   = each.key
      container_port   = load_balancer.value.container_port
    }
  }

  dynamic "service_registries" {
    for_each = each.value.service_discovery != null ? [each.value.service_discovery] : []
    content {
      registry_arn   = aws_service_discovery_service.this[each.key].arn
      container_name = each.key
      container_port = service_registries.value.container_port
    }
  }

  dynamic "deployment_configuration" {
    for_each = each.value.deployment_configuration != null ? [each.value.deployment_configuration] : []
    content {
      maximum_percent         = deployment_configuration.value.maximum_percent
      minimum_healthy_percent = deployment_configuration.value.minimum_healthy_percent
    }
  }

  depends_on = [aws_lb_target_group.this]

  tags = var.tags
}

# Target Groups
resource "aws_lb_target_group" "this" {
  for_each = local.target_groups

  name        = "${var.cluster_name}-${each.value.service_name}-${each.value.tg_name}"
  port        = each.value.port
  protocol    = each.value.protocol
  vpc_id      = each.value.vpc_id
  target_type = "ip"

  health_check {
    enabled             = each.value.health_check.enabled
    healthy_threshold   = each.value.health_check.healthy_threshold
    interval            = each.value.health_check.interval
    matcher             = each.value.health_check.matcher
    path                = each.value.health_check.path
    port                = each.value.health_check.port
    protocol            = each.value.health_check.protocol
    timeout             = each.value.health_check.timeout
    unhealthy_threshold = each.value.health_check.unhealthy_threshold
  }

  tags = var.tags
}

# Service Discovery Namespace
resource "aws_service_discovery_private_dns_namespace" "this" {
  count = var.service_discovery_namespace != null ? 1 : 0

  name = var.service_discovery_namespace.name
  vpc  = var.service_discovery_namespace.vpc_id

  tags = var.tags
}

# Service Discovery Service
resource "aws_service_discovery_service" "this" {
  for_each = {
    for k, v in var.services : k => v
    if v.service_discovery != null
  }

  name = each.key

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.this[0].id

    dns_records {
      ttl  = each.value.service_discovery.dns_ttl
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_grace_period_seconds = each.value.service_discovery.health_check_grace_period

  tags = var.tags
}

# Data sources
data "aws_region" "current" {}

# Local values for dynamic target group creation
locals {
  target_groups = {
    for tg in flatten([
      for service_name, service in var.services : [
        for tg_name, tg_config in service.target_groups : {
          key          = "${service_name}-${tg_name}"
          service_name = service_name
          tg_name      = tg_name
          port         = tg_config.port
          protocol     = tg_config.protocol
          vpc_id       = tg_config.vpc_id
          container_port = tg_config.container_port
          health_check = tg_config.health_check
        }
      ]
    ]) : tg.key => tg
  }
}