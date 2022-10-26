terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region                   = "ap-northeast-1"
  shared_credentials_files = ["$HOME/.aws/credentials"]
  profile                  = "default"
}

module "backend_s3_and_dynamoDB" {
  source        = "../../modules/backend_s3_dynamoDB"
  bucket_name   = var.bucket_name
  dynamoDB_name = var.dynamoDB_name
}
