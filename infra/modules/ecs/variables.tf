variable "owner" {
  type = string
}

variable "alb_target_group_arn" {
  type = string
}

variable "image_url" {
  type = string
}

variable "image_tag" {
  type = string
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
