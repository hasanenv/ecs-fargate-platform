resource "aws_ssm_parameter" "gatus_config" {
  name  = "/gatus/config"
  type  = "String"
  value = file("${path.root}/config/config.yaml")

  tags = local.tags
}
