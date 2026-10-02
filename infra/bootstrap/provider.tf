terraform {
  required_version = "~> 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.25.0"
    }
  }

  # Partial configuration: pass bucket, region and dynamodb_table with -backend-config
  # and use key=bootstrap/terraform.tfstate so this root never shares state with infra/.
  backend "s3" {}
}

provider "aws" {
  region = var.aws_region
}
