variable "cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

variable "cluster_settings" {
  description = "List of cluster settings"
  type = list(object({
    name  = string
    value = string
  }))
  default = [
    {
      name  = "containerInsights"
      value = "enabled"
    }
  ]
}

variable "cluster_configuration" {
  description = "Cluster configuration block"
  type = object({
    execute_command_configuration = optional(object({
      kms_key_id = optional(string)
      logging    = optional(string, "DEFAULT")
      log_configuration = optional(object({
        cloud_watch_encryption_enabled = optional(bool)
        cloud_watch_log_group_name     = optional(string)
        s3_bucket_name                 = optional(string)
        s3_bucket_encryption_enabled   = optional(bool)
        s3_key_prefix                  = optional(string)
      }))
    }))
  })
  default = null
}

variable "capacity_providers" {
  description = "List of capacity providers for the cluster"
  type        = list(string)
  default     = ["FARGATE", "FARGATE_SPOT"]
}

variable "default_capacity_provider_strategy" {
  description = "Default capacity provider strategy for the cluster"
  type = list(object({
    capacity_provider = string
    weight           = optional(number, 1)
    base             = optional(number, 0)
  }))
  default = [
    {
      capacity_provider = "FARGATE"
      weight           = 1
      base             = 1
    }
  ]
}

variable "services" {
  description = "Map of ECS services to create"
  type = map(object({
    image                = string
    cpu                  = number
    memory               = number
    desired_count        = number
    subnet_ids           = list(string)
    security_group_ids   = list(string)
    assign_public_ip     = optional(bool, false)
    execution_role_arn   = string
    task_role_arn       = optional(string)
    log_retention_days   = optional(number, 7)
    log_kms_key_id      = optional(string)

    container_ports = list(object({
      container_port = number
      host_port      = optional(number)
      protocol       = optional(string, "tcp")
    }))

    environment_variables = optional(list(object({
      name  = string
      value = string
    })), [])

    secrets = optional(list(object({
      name       = string
      value_from = string
    })), [])

    health_check = optional(object({
      command      = list(string)
      interval     = optional(number, 30)
      timeout      = optional(number, 5)
      retries      = optional(number, 3)
      start_period = optional(number, 60)
    }))

    target_groups = optional(map(object({
      port           = number
      protocol       = string
      vpc_id         = string
      container_port = number
      health_check = object({
        enabled             = optional(bool, true)
        healthy_threshold   = optional(number, 2)
        interval            = optional(number, 30)
        matcher             = optional(string, "200")
        path                = optional(string, "/")
        port                = optional(string, "traffic-port")
        protocol            = optional(string, "HTTP")
        timeout             = optional(number, 5)
        unhealthy_threshold = optional(number, 2)
      })
    })), {})

    service_discovery = optional(object({
      container_port              = number
      dns_ttl                    = optional(number, 60)
      health_check_grace_period  = optional(number, 60)
    }))

    deployment_configuration = optional(object({
      maximum_percent         = optional(number, 200)
      minimum_healthy_percent = optional(number, 100)
    }))
  }))
}

variable "service_discovery_namespace" {
  description = "Service discovery namespace configuration"
  type = object({
    name   = string
    vpc_id = string
  })
  default = null
}

variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default     = {}
}