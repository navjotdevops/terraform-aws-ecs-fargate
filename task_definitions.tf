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