output "cluster_id" {
  description = "ID of the ECS cluster"
  value       = aws_ecs_cluster.this.id
}

output "cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = aws_ecs_cluster.this.arn
}

output "cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.this.name
}

output "service_arns" {
  description = "ARNs of the ECS services"
  value       = { for k, v in aws_ecs_service.this : k => v.id }
}

output "service_names" {
  description = "Names of the ECS services"
  value       = { for k, v in aws_ecs_service.this : k => v.name }
}

output "task_definition_arns" {
  description = "ARNs of the task definitions"
  value       = { for k, v in aws_ecs_task_definition.this : k => v.arn }
}

output "target_group_arns" {
  description = "ARNs of the target groups"
  value       = { for k, v in aws_lb_target_group.this : k => v.arn }
}

output "cloudwatch_log_groups" {
  description = "Names of the CloudWatch log groups"
  value       = { for k, v in aws_cloudwatch_log_group.this : k => v.name }
}

output "service_discovery_service_arns" {
  description = "ARNs of the service discovery services"
  value       = { for k, v in aws_service_discovery_service.this : k => v.arn }
}

output "service_discovery_namespace_id" {
  description = "ID of the service discovery namespace"
  value       = length(aws_service_discovery_private_dns_namespace.this) > 0 ? aws_service_discovery_private_dns_namespace.this[0].id : null
}

output "service_discovery_namespace_arn" {
  description = "ARN of the service discovery namespace"
  value       = length(aws_service_discovery_private_dns_namespace.this) > 0 ? aws_service_discovery_private_dns_namespace.this[0].arn : null
}