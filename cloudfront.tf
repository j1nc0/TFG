/*
resource "aws_cloudfront_origin_access_identity" "OAI" {
  comment = "OAI form cloudfront"
}
*/

resource "random_string" "origin_token" {
  length  = 30
  special = false
}

resource "aws_cloudfront_distribution" "alb_distribution" {

  comment = "Cloudfront distribution used to serve static contents of a Wordpress web page faster"
  enabled = true

  web_acl_id = aws_wafv2_web_acl.web_acl.arn

  origin {
    domain_name = aws_lb.alb_awstp.dns_name
    origin_id   = aws_lb.alb_awstp.dns_name

    custom_header {
      name  = "X-Origin-Token"
      value = random_string.origin_token.result
    }

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
    /*
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.OAI.cloudfront_access_identity_path
    }
    */
  }

  aliases = [var.domain, "www.${var.domain}"]

  default_cache_behavior {
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = aws_lb.alb_awstp.dns_name
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values { //demà mirar què fan els forwarded values!
      query_string = true
      headers      = ["Host"]

      cookies {
        forward = "all"
      }
    }

    min_ttl     = 0
    default_ttl = 3600  # 1h
    max_ttl     = 86400 # 1 dia
  }

  price_class = "PriceClass_All"


  restrictions {
    geo_restriction {
      restriction_type = var.georestrictions_cloudfornt == null ? "none" : "blacklist"
      locations        = var.georestrictions_cloudfornt == null ? null : var.georestrictions_cloudfornt
    }
  }


  tags = local.tags

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.cert.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}
