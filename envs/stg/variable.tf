# environment prefix
variable "env" {
  type    = string
  default = "stg"
}

# vpc related
variable "vpc_cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}
variable "azs" {
  type    = list(string)
  default = ["ap-northeast-1a", "ap-northeast-1c"]
}
variable "public_subnets" {
  type    = list(string)
  default = ["10.0.0.0/24", "10.0.1.0/24"]
}
variable "private_app_subnets" {
  type    = list(string)
  default = ["10.0.8.0/24", "10.0.9.0/24"]

}
variable "private_db_subnets" {
  type    = list(string)
  default = ["10.0.16.0/24", "10.0.17.0/24"]
}
variable "private_name_space" {
  type    = string
  default = "myapp.local"
}
variable "peering_vpc_id" {
  type    = string
  default = "vpc-xxxxx"
}
variable "peering_vpc_owner_account_id" {
  type    = string
  default = "xxxxxxx"
}
variable "peering_vpc_cidr_block" {
  type    = string
  default = "10.1.0.0/16"
}

# Route53 related
variable "root_domain_name" { type = string }
variable "subdomain1_name" {
  type    = string
  default = "stg"
}
variable "root_domain_zone_id" { type = string }

# ECS related
variable "cpu" {
  type    = string
  default = "256"
}
variable "memory" {
  type    = string
  default = "512"
}
variable "desired_count" {
  type    = number
  default = 1
}
variable "logs_retention_in_days" {
  type    = number
  default = 30
}

# CodePipeline related
variable "artifact_bucket_name" {
  type    = string
  default = "artifact-bucket-myapp"
}
variable "frontend_build_output_json" {
  type    = string
  default = "frontendImageDifinitions.json"
}
variable "github_connection_arn" {
  type = string
}
variable "frontend_full_repository_id" {
  type    = string
  default = "yasuhiko-nara/sbcntr-frontend"
}
variable "branch" {
  type    = string
  default = "main"
}
