variable "aws_account_id" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "github_repo" {
  description = "GitHub repository in the format owner/repo for the OIDC trust relationship."
  type        = string
}

variable "owner" {
  type = string
}

variable "tf_state_bucket" {
  description = "S3 bucket holding Terraform state (scopes the CI/CD role policies)."
  type        = string
}

variable "tf_lock_table" {
  description = "DynamoDB table used for Terraform state locking (scopes the CI/CD role policies)."
  type        = string
}
