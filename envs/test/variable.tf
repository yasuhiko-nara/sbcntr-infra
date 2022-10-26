# environment prefix
variable "env" {
  type    = string
  default = "test"
}

# vpc related
variable "vpc_cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}
