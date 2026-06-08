terraform {
  backend "s3" {
    bucket         = "terraform-org-state-817690546479"
    key            = "identity-center/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-org-state-lock"
    encrypt        = true
  }

  required_version = ">= 1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.46"
    }
  }
}
