# import root host zone
# need to configure manually 
# @see https://blog.i-tale.jp/2020/04/13_02/
data "aws_route53_zone" "root" {
  name = var.root_domain_name
}
resource "aws_route53_record" "root" {
  zone_id = data.aws_route53_zone.root.zone_id
  name    = data.aws_route53_zone.root.name
  type    = "A"
  alias {
    name                   = aws_lb.this.dns_name
    zone_id                = aws_lb.this.zone_id
    evaluate_target_health = true
  }
}

# subdomain
resource "aws_route53_record" "subdomain_stg" {
  zone_id = data.aws_route53_zone.root.zone_id
  name    = "${var.subdomain1_name}.${data.aws_route53_zone.root.name}"
  type    = "A"
  alias {
    name                   = aws_lb.this.dns_name
    zone_id                = aws_lb.this.zone_id
    evaluate_target_health = true
  }
}
