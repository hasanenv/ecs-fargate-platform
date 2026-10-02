output "docker_build_push_role_arn" {
  value = aws_iam_role.docker_build_push_role.arn
}

output "terraform_apply_role_arn" {
  value = aws_iam_role.terraform_apply_role.arn
}

output "manual_destroy_role_arn" {
  value = aws_iam_role.manual_destroy_role.arn
}
