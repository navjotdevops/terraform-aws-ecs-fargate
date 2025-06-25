# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "this" {
  for_each = var.services

  name              = "/ecs/${var.cluster_name}/${each.key}"
  retention_in_days = each.value.log_retention_days
  kms_key_id        = each.value.log_kms_key_id

  tags = var.tags
}