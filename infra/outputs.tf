output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.alb.alb_dns_name
}

output "service_url" {
  description = "Public URL of the Gatus service"
  value       = "https://tm.${data.aws_route53_zone.domain.name}"
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = module.ecs.cluster_name
}

output "ecs_service_name" {
  description = "ECS service name"
  value       = module.ecs.service_name
}

output "gatus_config_ssm_arn" {
  description = "ARN of the SSM Parameter Store entry containing Gatus config"
  value       = aws_ssm_parameter.gatus_config.arn
}