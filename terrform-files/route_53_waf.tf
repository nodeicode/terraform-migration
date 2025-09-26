# WAF - Ensure this is created in the same region as the ALB or CloudFront if attaching there
resource "aws_wafv2_web_acl" "main" {
  name        = "kuali-web-acl-2az"
  description = "WAF ACL for Kuali Application"
  scope       = "REGIONAL" # For ALB. Use "CLOUDFRONT" for CloudFront distribution
  default_action { allow {} }

  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 1
    override_action { none {} }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesCommonRuleSet"
      sampled_requests_enabled   = true
    }
  }
  rule {
    name     = "AWSManagedRulesSQLiRuleSet"
    priority = 2
    override_action { none {} }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesSQLiRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesSQLiRuleSet"
      sampled_requests_enabled   = true
    }
  }
  rule {
    name     = "RateLimit5000Per5Min"
    priority = 3
    action { block {} }
    statement {
      rate_based_statement {
        limit              = 5000
        aggregate_key_type = "IP"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "RateLimit5000"
      sampled_requests_enabled   = true
    }
  }
  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "kualiWebAcl2AZ"
    sampled_requests_enabled   = true
  }
  tags = { Name = "Kuali-WAF-ACL-2AZ" }
}

resource "aws_wafv2_web_acl_association" "alb_waf" {
  resource_arn = aws_lb.main.arn # Associate WAF with ALB
  web_acl_arn  = aws_wafv2_web_acl.main.arn
}

# Route 53 records will be defined in s3_cloudfront.tf if CloudFront is the main entry point
# If ALB is the main entry point (no CloudFront), define them here:
# resource "aws_route53_record" "alb_alias_apex" {
#   zone_id = aws_route53_zone.main.id
#   name    = aws_route53_zone.main.name
#   type    = "A"
#   alias {
#     name                   = aws_lb.main.dns_name
#     zone_id                = aws_lb.main.zone_id
#     evaluate_target_health = true
#   }
# }
# resource "aws_route53_record" "alb_alias_www" {
#   zone_id = aws_route53_zone.main.id
#   name    = "www.${aws_route53_zone.main.name}"
#   type    = "A"
#   alias {
#     name                   = aws_lb.main.dns_name
#     zone_id                = aws_lb.main.zone_id
#     evaluate_target_health = true
#   }
# }
