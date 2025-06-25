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