terraform {
  backend "s3" {
    bucket       = "terraform-org-state-817690546479"
    key          = "org/terraform.tfstate"
    region       = "ap-south-1"
    use_lockfile = true
    encrypt      = true
  }

  required_version = ">= 1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.46"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.2"
    }
  }
}
