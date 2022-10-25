variable "bucket_name" {
  type    = string
  default = "tfstate-bucket"
}
variable "dynamoDB_name" {
  type    = string
  default = "terraform_state_lock"
}
