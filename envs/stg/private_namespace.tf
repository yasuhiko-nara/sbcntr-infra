resource "aws_service_discovery_private_dns_namespace" "this" {
  name        = var.private_name_space
  description = "private name space used for ecs service discovery"
  vpc         = aws_vpc.this.id
}
