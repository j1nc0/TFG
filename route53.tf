resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.aws_registred.zone_id
  name    = var.domain
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.alb_distribution.domain_name
    evaluate_target_health = true
    zone_id                = "Z2FDTNDATAQYW2" #default hosted zone of cloudfront
  }
}

resource "aws_route53_record" "cname" {
  zone_id = data.aws_route53_zone.aws_registred.zone_id
  name    = "www.${var.domain}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${var.domain}"]
}

#SSL cert Cloudfront

resource "aws_acm_certificate" "cert" {
  provider                  = aws.us-east-1
  domain_name               = var.domain
  validation_method         = "DNS"
  subject_alternative_names = ["*.${var.domain}"]

  tags = {
    Name        = "${var.project_name}-${var.workspace}-Cloudfront-cert"
    Project     = "${var.project_name}"
    Environment = "${var.workspace}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "validation" {
  provider                = aws.us-east-1
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.validation_record : record.fqdn]
}

resource "aws_route53_record" "validation_record" {
  for_each = {
    for item in aws_acm_certificate.cert.domain_validation_options : item.domain_name => {
      name   = item.resource_record_name
      record = item.resource_record_value
      type   = item.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.aws_registred.zone_id
}

#SSL cert ALB

resource "aws_acm_certificate" "cert-alb" {
  domain_name               = var.domain
  validation_method         = "DNS"
  subject_alternative_names = ["*.${var.domain}"]

  tags = {
    Name        = "${var.project_name}-${var.workspace}-ALB-cert"
    Project     = "${var.project_name}"
    Environment = "${var.workspace}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "validation-alb" {
  certificate_arn         = aws_acm_certificate.cert-alb.arn
  validation_record_fqdns = [for record in aws_route53_record.validation_record-alb : record.fqdn]
}

resource "aws_route53_record" "validation_record-alb" {
  for_each = {
    for item in aws_acm_certificate.cert-alb.domain_validation_options : item.domain_name => {
      name   = item.resource_record_name
      record = item.resource_record_value
      type   = item.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.aws_registred.zone_id
}
