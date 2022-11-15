terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"

  backend "s3" {
    bucket                  = "sbcntr-infra-staging"
    key                     = "stg/terraform.tfstate"
    region                  = "ap-northeast-1"
    dynamodb_table          = "terraform_state_lock"
    shared_credentials_file = "$HOME/.aws/credentials"
    profile                 = "default"
  }
}

provider "aws" {
  region                   = "ap-northeast-1"
  shared_credentials_files = ["$HOME/.aws/credentials"]
  profile                  = "default"
}

provider "aws" {
  region                   = "ap-northeast-1"
  alias                    = "second_account"
  shared_credentials_files = ["$HOME/.aws/credentials"]
  profile                  = "nara-2nd-account"
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_caller_identity" "second_account" {
  provider = aws.second_account
}
