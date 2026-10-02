output "docker_build_push_role_arn" {
  value = module.cicd_iam.docker_build_push_role_arn
}

output "terraform_apply_role_arn" {
  value = module.cicd_iam.terraform_apply_role_arn
}

output "manual_destroy_role_arn" {
  value = module.cicd_iam.manual_destroy_role_arn
}

output "ecr_repository_url" {
  value = module.ecr.repository_url
}
