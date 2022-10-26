variable "bucket_name" {
  type    = string
  default = "test-bucket-202210261957"
}
variable "dynamoDB_name" {
  type    = string
  default = "terraform-state-lock-test"
}
