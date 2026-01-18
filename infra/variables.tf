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