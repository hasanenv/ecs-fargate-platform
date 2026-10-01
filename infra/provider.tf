terraform {
  required_version = "~> 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.25.0"
    }
  }

  # Partial configuration: bucket, key, region and dynamodb_table are supplied
  # at init time with -backend-config (see .github/workflows and README Quick Start).
  backend "s3" {}
}

provider "aws" {
  region = var.aws_region
}
