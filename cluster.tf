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