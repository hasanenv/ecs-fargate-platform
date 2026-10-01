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

variable "owner" {
  type = string
}
variable "aws_region" {
  description = "Region of the DynamoDB lock table (used to build its ARN)."
  type        = string
}

variable "tf_state_bucket" {
  description = "S3 bucket holding Terraform state."
  type        = string
}

variable "tf_lock_table" {
  description = "DynamoDB table used for Terraform state locking."
  type        = string
}
