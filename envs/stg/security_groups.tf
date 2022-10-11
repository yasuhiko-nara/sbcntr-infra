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
