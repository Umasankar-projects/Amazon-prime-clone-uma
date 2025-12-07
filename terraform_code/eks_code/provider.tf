terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.70"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  
  # ✅ CRITICAL: Default timeouts for destroy
  default_tags {
    tags = local.tags
  }
}

# ✅ Global timeouts for stubborn resources
terraform {
  # Add after provider block
  timeouts {}
}
