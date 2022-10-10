# ACM
resource "aws_acm_certificate" "this" {
  domain_name               = aws_route53_record.root.name
  subject_alternative_names = ["*.${aws_route53_record.root.name}"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}
