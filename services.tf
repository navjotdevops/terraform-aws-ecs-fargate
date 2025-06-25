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