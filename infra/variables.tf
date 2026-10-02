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

variable "availability_zones" {
  type = list(string)
}

variable "owner" {
  type = string
}

# -------------------------
# DNS / TLS
# -------------------------
variable "domain_name" {
  description = "Public Route 53 hosted zone name. The service is published at tm.<domain_name>."
  type        = string
}
