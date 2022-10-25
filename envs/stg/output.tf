# VPC related
output "vpc_id" {
  value = aws_vpc.this.id
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

# ALB related
output "alb_dns_name" {
  value = aws_lb.this.dns_name
}

# Route53 related
output "domain_name_root" {
  value = aws_route53_record.root.name
}
output "domain_name_subdomain_stg" {
  value = aws_route53_record.subdomain_stg.name
}
