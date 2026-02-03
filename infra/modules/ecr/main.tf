resource "aws_ecr_repository" "gatus" {
  name                 = "gatus-repo"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = local.tags
}
