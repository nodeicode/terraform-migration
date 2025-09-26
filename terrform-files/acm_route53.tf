resource "aws_route53_zone" "main" {
  name = "kuali.tech" # Your domain name
  tags = { Name = "Kuali-HostedZone" }
}

resource "aws_acm_certificate" "main" {
  provider                  = aws.us_east_1_acm
  domain_name               = aws_route53_zone.main.name
  subject_alternative_names = ["www.${aws_route53_zone.main.name}"]
  validation_method         = "DNS"
  tags = { Name = "Kuali-Cert" }
  lifecycle { create_before_destroy = true }
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.main.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.main.id
}

resource "aws_acm_certificate_validation" "main" {
  provider                = aws.us_east_1_acm
  certificate_arn         = aws_acm_certificate.main.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

