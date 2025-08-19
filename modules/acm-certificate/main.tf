terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6"
    }
  }
}

resource "aws_acm_certificate" "this" {
  domain_name               = var.fqdn
  subject_alternative_names = concat(["*.${var.fqdn}"], var.additional_fqdns)
  validation_method         = "DNS"
}

resource "aws_route53_record" "acm_validation" {
  for_each = {
    for record in aws_acm_certificate.this.domain_validation_options : record.domain_name => {
      name   = record.resource_record_name
      record = record.resource_record_value
      type   = record.resource_record_type
    }
  }
  allow_overwrite = true
  zone_id         = var.route53_zone_id
  name            = each.value.name
  type            = each.value.type
  records         = [each.value.record]
  ttl             = 300
}

resource "aws_acm_certificate_validation" "this" {
  certificate_arn         = aws_acm_certificate.this.arn
  validation_record_fqdns = [for record in aws_route53_record.acm_validation : record.fqdn]
}