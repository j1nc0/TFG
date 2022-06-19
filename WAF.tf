module "waf" {
  source = "coresolutions-ltd/wafv2/aws"

  name_prefix    = "${var.project_name}-${var.workspace}-ALB-WAF"
  default_action = "block"
  scope          = "REGIONAL"
  origin_token   = random_string.origin_token.result
}

resource "aws_wafv2_web_acl_association" "waf_association" {
  resource_arn = aws_lb.alb_awstp.arn
  web_acl_arn  = module.waf.waf_arn
}

locals {
  managed_rules = ["AWSManagedRulesCommonRuleSet",
    "AWSManagedRulesAmazonIpReputationList",
    "AWSManagedRulesAdminProtectionRuleSet",
    "AWSManagedRulesKnownBadInputsRuleSet",
    "AWSManagedRulesLinuxRuleSet",
  "AWSManagedRulesUnixRuleSet"]
}

resource "aws_wafv2_web_acl" "web_acl" {
  name        = "${var.project_name}-${var.workspace}-Cloudfront-WAF"
  description = "Web ACL - Cloudfront"
  scope       = "CLOUDFRONT"
  provider    = aws.us-east-1

  default_action {
    allow {}
  }

  dynamic "rule" {
    for_each = local.managed_rules

    content {
      name     = "Cloudfront-WAF-${rule.value}"
      priority = 50 + index(local.managed_rules, rule.value)

      override_action {
        none {}
      }

      statement {
        managed_rule_group_statement {
          name        = rule.value
          vendor_name = "AWS"
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = false
        metric_name                = "Cloudfront-WAF${rule.value}"
        sampled_requests_enabled   = false
      }

    }
  }


  rule {

    name     = "Cloudfront-WAF-Ratelimiting"
    priority = 100

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 1000
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "Cloudfront-WAF-Ratelimiting"
      sampled_requests_enabled   = false
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "Cloudfront-WAF-CDefaultAction"
    sampled_requests_enabled   = false
  }

  tags = {
    "Name" = "Cloudfront-WAF-WAF"
  }
}