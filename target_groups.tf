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