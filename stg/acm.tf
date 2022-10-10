# ACM
resource "aws_acm_certificate" "this" {
  domain_name               = aws_route53_record.root.name
  subject_alternative_names = ["*.${aws_route53_record.root.name}"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# validation
resource "aws_route53_record" "validation_certificate" {
  for_each = {
    for dvo in aws_acm_certificate.this.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
  zone_id = data.aws_route53_zone.root.id
  ttl     = 60
}

resource "aws_acm_certificate_validation" "this" {
  certificate_arn = aws_acm_certificate.this.arn
  validation_record_fqdns = [
    for record in aws_route53_record.validation_certificate : record.fqdn
  ]
}
