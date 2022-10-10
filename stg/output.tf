# output "iam_role_arn" {
#   value = module.describe_region_for_ec2.iam_role_arn
# }

# output "iam_role_name" {
#   value = module.describe_region_for_ec2.iam_role_name
# }

# VPC related
output "vpc_id" {
  value = aws_vpc.stg.id
}
output "subnet_id_public_1a" {
  value = aws_subnet.public_1a.id
}
output "subnet_id_public_1c" {
  value = aws_subnet.public_1c.id
}
output "subnet_id_private_app_1a" {
  value = aws_subnet.private_app_1a.id
}
output "subnet_id_private_app_1c" {
  value = aws_subnet.private_app_1c.id
}
output "subnet_id_private_db_1a" {
  value = aws_subnet.private_db_1a.id
}
output "subnet_id_private_db_1c" {
  value = aws_subnet.private_db_1c.id
}

