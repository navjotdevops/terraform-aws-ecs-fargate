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