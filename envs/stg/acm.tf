# ACM
resource "aws_acm_certificate" "this" {
  domain_name               = aws_route53_record.root.name
  subject_alternative_names = ["*.${aws_route53_record.root.name}"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# https://dev.classmethod.jp/articles/terraform-acm-alb-associate/
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.this.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  type            = each.value.type
  ttl             = "300"

  zone_id = var.root_domain_zone_id
}

resource "aws_acm_certificate_validation" "this" {
  certificate_arn = aws_acm_certificate.this.arn
  validation_record_fqdns = [
    for record in aws_route53_record.cert_validation : record.fqdn
  ]
}
