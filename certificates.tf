# Create cert
resource aws_acm_certificate cert {
  provider          = aws.us_east_1
  validation_method = "DNS"

  domain_name               = local.app_domain_name

  lifecycle {
    create_before_destroy = true    # Minimizes down time on cert replacement
  }
}


# Create DNS validation record(s)
data aws_route53_zone main {
  provider = aws.us_east_1
  name     = local.hosted_zone_domain_name
}


resource aws_route53_record cert_validation {
  provider = aws.us_east_1
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  name    = each.value.name
  type    = each.value.type
  zone_id = data.aws_route53_zone.main.zone_id
  records = [each.value.record]
  ttl     = 60
}

# Validate the certificate
resource aws_acm_certificate_validation cert {
  provider                = aws.us_east_1
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [
    for record in aws_route53_record.cert_validation : record.fqdn
  ]
}
