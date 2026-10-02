variable "owner" {
  type = string
}

variable "alb_target_group_arn" {
  type = string
}

variable "ecr_repository_url" {
  description = "URL of the ECR repository holding the Gatus image (managed by infra/bootstrap)."
  type        = string
}

variable "ecs_task_execution_role_arn" {
  type = string
}

variable "ecs_service_sg_id" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "gatus_config_ssm_arn" {
  type = string
}
