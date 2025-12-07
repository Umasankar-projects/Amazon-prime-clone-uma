terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.70"  # Compatible with v19.15.1 [web:11]
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

