output "cluster_name" {
  description = "Name of the ECS cluster"
  value       = module.ecs_fargate.cluster_name
}

output "service_arns" {
  description = "ARNs of the ECS services"
  value       = module.ecs_fargate.service_arns
}

output "load_balancer_dns" {
  description = "DNS name of the load balancer"
  value       = aws_lb.main.dns_name
}

output "target_group_arns" {
  description = "ARNs of the target groups"
  value       = module.ecs_fargate.target_group_arns
}