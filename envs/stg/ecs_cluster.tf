resource "aws_ecs_cluster" "this" {
  name = "${var.env}-sbcntr-cluster"
}

# stg環境なのでFargate Spotのみ使う
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster_capacity_providers
resource "aws_ecs_cluster_capacity_providers" "this" {
  cluster_name = aws_ecs_cluster.this.name

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    weight            = 1
    capacity_provider = "FARGATE_SPOT"
  }
}
