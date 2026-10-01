# -------------------------
# Network
# -------------------------
variable "vpc_cidr" {
  type = string
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "private_subnet_cidrs" {
  type = list(string)
}

# -------------------------
# Environment / policy
# -------------------------
variable "aws_region" {
  type = string
}

variable "aws_account_id" {
  type = string
}

variable "availability_zones" {
  type = list(string)
}

variable "owner" {
  type = string
}

# -------------------------
# Deployment
# -------------------------

variable "github_repo" {
  type = string
}
# -------------------------
# DNS / TLS
# -------------------------
variable "domain_name" {
  description = "Public Route 53 hosted zone name. The service is published at tm.<domain_name>."
  type        = string
}

# -------------------------
# Terraform state (used only to scope IAM policies; the backend itself is configured with -backend-config)
# -------------------------
variable "tf_state_bucket" {
  description = "S3 bucket holding Terraform state."
  type        = string
}

variable "tf_lock_table" {
  description = "DynamoDB table used for Terraform state locking."
  type        = string
}
