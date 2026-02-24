resource "aws_wafv2_web_acl" "cloudfront_waf" {
  name     = "staff-leave-waf"
  scope    = "CLOUDFRONT" # Essential for CloudFront
  provider = aws.us_east_1    # Ensure you have a provider alias for us-east-1

  default_action {
    allow {}
  }

  # Add the managed Amazon Common Rule Set (protects against SQLi, XSS, etc.)
  rule {
    name     = "AWS-AWSManagedRulesCommonRuleSet"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "awsCommonRules"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "staffLeaveWAF"
    sampled_requests_enabled   = true
  }
}
