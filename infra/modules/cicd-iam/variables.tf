variable "aws_account_id" {
  description = "AWS account ID. Used for the OIDC provider ARN and the DynamoDB lock table ARN."
  type        = string
}

variable "aws_region" {
  description = "Region of the DynamoDB lock table (used to build its ARN)."
  type        = string
}

variable "github_repo" {
  description = "GitHub repository in the format owner/repo for the OIDC trust relationship."
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
