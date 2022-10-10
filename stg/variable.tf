# environment prefix
variable "env" {}

# vpc related
variable "vpc_cidr_block" {}
variable "azs" {
  type = list(string)
}
variable "public_subnets" {
  type = list(string)
}
variable "private_app_subnets" {
  type = list(string)
}
variable "private_db_subnets" {
  type = list(string)
}

# Route53 related
variable "root_domain_name" {}
variable "subdomain1_name" {}

