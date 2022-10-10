# environment prefix
variable "env" {
  default = "stg"
}

# vpc related
variable "vpc_cidr_block" {
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

# Route53 related
variable "root_domain_name" {}
variable "subdomain1_name" { default = "stg" }

