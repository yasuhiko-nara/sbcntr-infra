# ALB
module "http_sg" {
  source      = "../../modules/sg_cidr_blocks"
  name        = "${var.env}-alb-http-sg"
  vpc_id      = aws_vpc.this.id
  port        = 80
  cidr_blocks = ["0.0.0.0/0"]
}
module "https_sg" {
  source      = "../../modules/sg_cidr_blocks"
  name        = "${var.env}-alb-https-sg"
  vpc_id      = aws_vpc.this.id
  port        = 443
  cidr_blocks = ["0.0.0.0/0"]
}

# frontend service
module "frontend_sg" {
  source                   = "../../modules/sg_source_security_group_id"
  name                     = "${var.env}-frontend-sg"
  vpc_id                   = aws_vpc.this.id
  port                     = 80
  source_security_group_id = module.https_sg.security_group_id
}

# backend service
module "backend_sg" {
  source                   = "../../modules/sg_source_security_group_id"
  name                     = "${var.env}-backend-sg"
  vpc_id                   = aws_vpc.this.id
  port                     = 80
  source_security_group_id = module.frontend_sg.security_group_id
}
module "backend_sg_peer" {
  source      = "../../modules/sg_cidr_blocks"
  name        = "${var.env}-backend-sg-peer"
  vpc_id      = aws_vpc.this.id
  port        = 80
  cidr_blocks = ["10.0.0.0/16"]
}

# CodeBuild
resource "aws_security_group" "codebuild" {
  name   = "${var.env}-codebuild"
  vpc_id = aws_vpc.this.id
}
resource "aws_security_group_rule" "codebuild_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.codebuild.id
}
