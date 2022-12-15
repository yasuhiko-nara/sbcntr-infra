terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"

  backend "s3" {
    bucket                  = "sbcntr-infra-2nd-account"
    key                     = "stg/terraform.tfstate"
    region                  = "ap-northeast-1"
    dynamodb_table          = "terraform_state_lock"
    shared_credentials_file = "$HOME/.aws/credentials"
    profile                 = "nara-2nd-account"
  }
}

provider "aws" {
  region                   = "ap-northeast-1"
  shared_credentials_files = ["$HOME/.aws/credentials"]
  profile                  = "nara-2nd-account"
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}
