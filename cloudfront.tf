# Fetch current AWS account ID dynamically
# Used to build the CloudFront ARN in the S3 bucket policy
data "aws_caller_identity" "current" {}




# -------------------------------------------------------
# ORIGIN ACCESS CONTROL (OAC)
# Modern replacement for Origin Access Identity (OAI)
# Signs every CloudFront → S3 request with SigV4
# -------------------------------------------------------
resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "s3-oac-${aws_s3_bucket.vendors_bucket.id}"
  description                       = "OAC for CloudFront to access private S3 vendors bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always" # Sign every request to S3
  signing_protocol                  = "sigv4"  # AWS Signature Version 4
}

# -------------------------------------------------------
# CLOUDFRONT DISTRIBUTION
# Two origins:
#   1. EC2/ALB  → handles all PHP requests (no cache)
#   2. S3       → handles /vendors/* (1 year cache)
# -------------------------------------------------------
resource "aws_cloudfront_distribution" "main" {
  enabled         = true
  is_ipv6_enabled = true
  web_acl_id      = aws_wafv2_web_acl.cloudfront_waf.arn
  # NOTE: CloudFront cannot EXECUTE PHP.
  # It fetches index.php from EC2/ALB which runs it.
  # This only applies to direct root "/" requests.
  default_root_object = "index.php"

  # Your custom domain + all subdomains
  # IMPORTANT: Your ACM certificate (SLV_cert) must cover
  # BOTH var.domain_name AND *.var.domain_name
  aliases = [var.domain_name, "*.${var.domain_name}"]

  # ==========================================================
  # ORIGIN 1: EC2 / ALB (PHP Application)
  # ==========================================================
  origin {
    domain_name = aws_lb.SLV_alb.dns_name
    origin_id   = "app-origin"

    custom_origin_config {
      http_port  = 80
      https_port = 443

      # IMPORTANT: Set to "https-only" only if your ALB has
      # an SSL certificate installed on port 443.
      # If ALB is HTTP only, temporarily use "http-only"
      # and switch back after ALB SSL is configured.
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  # ==========================================================
  # ORIGIN 2: S3 (Vendors Static Assets)
  # ==========================================================
  origin {
    # Use regional domain name (not global) to avoid
    # redirect issues and improve latency
    domain_name = aws_s3_bucket.vendors_bucket.bucket_regional_domain_name
    origin_id   = "vendors-origin"

    # Attach OAC so CloudFront can access private S3
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }

  # ==========================================================
  # DEFAULT BEHAVIOR → PHP APP (NO CACHE)
  # Matches ALL paths not caught by ordered_cache_behavior
  # ==========================================================
  default_cache_behavior {
    target_origin_id       = "app-origin"
    viewer_protocol_policy = "redirect-to-https"

    # All HTTP methods needed for full PHP app
    # (forms, login, leave requests, etc.)
    allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods  = ["GET", "HEAD"]

    compress = true

    forwarded_values {
      query_string = true                 # Forward ?id=1&page=2 to EC2
      cookies { forward = "all" }         # Forward session/login cookies
      headers = ["Authorization", "Host"] # Forward auth + host headers
    }

    # Zero TTL = no caching, every request hits EC2
    # Required for dynamic PHP pages
    min_ttl     = 0
    default_ttl = 0
    max_ttl     = 0
  }

  # ==========================================================
  # ORDERED BEHAVIOR 1 → S3 VENDORS (AGGRESSIVE CACHE)
  # Matches /vendors/* paths only
  # ==========================================================
  ordered_cache_behavior {
    path_pattern           = "/vendors/*"
    target_origin_id       = "vendors-origin"
    viewer_protocol_policy = "redirect-to-https"

    # Read-only — static files don't need write methods
    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    compress = true

    forwarded_values {
      query_string = false         # No query strings for static files
      cookies { forward = "none" } # No cookies for static files
    }

    # Aggressive 1-year cache for vendor libraries
    # (Bootstrap, jQuery, etc. never change)
    min_ttl     = 86400    # 1 day minimum
    default_ttl = 31536000 # 1 year default
    max_ttl     = 31536000 # 1 year maximum
  }

  # ==========================================================
  # CUSTOM ERROR PAGES
  # Handles S3 403/404 errors gracefully instead of
  # showing raw AWS error pages to users
  # ==========================================================
  custom_error_response {
    error_code            = 403
    response_code         = 404
    response_page_path    = "/404.php" # Update to match your 404 page
    error_caching_min_ttl = 10
  }

  custom_error_response {
    error_code            = 404
    response_code         = 404
    response_page_path    = "/404.php" # Update to match your 404 page
    error_caching_min_ttl = 10
  }

  # ==========================================================
  # SSL CERTIFICATE
  # CRITICAL: ACM certificate MUST be in us-east-1 region
  # regardless of where your other resources are deployed.
  # CloudFront only accepts certificates from us-east-1.
  # See variables.tf for provider alias configuration.
  # ==========================================================
  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.SLV_cert.arn
    ssl_support_method       = "sni-only"     # No extra cost (vs dedicated IP)
    minimum_protocol_version = "TLSv1.2_2021" # Drops old insecure TLS versions
  }

  restrictions {
    geo_restriction {
      restriction_type = "none" # No geo-blocking, accessible worldwide
    }
  }
}

# -------------------------------------------------------
# OUTPUTS
# -------------------------------------------------------
output "cloudfront_distribution_id" {
  description = "CloudFront Distribution ID - use for cache invalidations"
  value       = aws_cloudfront_distribution.main.id
}

output "cloudfront_domain_name" {
  description = "CloudFront domain - point your DNS CNAME here"
  value       = aws_cloudfront_distribution.main.domain_name
}

output "cloudfront_arn" {
  description = "CloudFront ARN - used in S3 bucket policy"
  value       = aws_cloudfront_distribution.main.arn
}
