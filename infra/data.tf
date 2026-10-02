data "aws_route53_zone" "domain" {
  name         = var.domain_name
  private_zone = false
}

# Created by infra/bootstrap. The plan fails fast here if bootstrap has not been applied.
data "aws_ecr_repository" "gatus" {
  name = "gatus-repo"
}
