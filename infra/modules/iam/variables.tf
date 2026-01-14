variable "cicd_role_name" {
  description = "Existing CI/CD IAM role name assumed via OIDC (created outside via console)."
  type        = string
}

variable "aws_account_id" {
  description = "AWS Account ID where the IAM role will be created."
  type        = string
}

variable "github_repo" {
  description = "GitHub repository in the format 'owner/repo' for OIDC trust relationship."
  type        = string
}

variable "image_tag" {
  type = string
}

variable "owner" {
  type = string
}