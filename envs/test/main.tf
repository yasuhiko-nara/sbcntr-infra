terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"

  backend "s3" {
    bucket                  = "test-bucket-202210261957"
    key                     = "stg/terraform.tfstate"
    region                  = "ap-northeast-1"
    dynamodb_table          = "terraform-state-lock-test"
    shared_credentials_file = "$HOME/.aws/credentials"
    profile                 = "default"
  }
}

provider "aws" {
  region                   = "ap-northeast-1"
  shared_credentials_files = ["$HOME/.aws/credentials"]
  profile                  = "default"
}

