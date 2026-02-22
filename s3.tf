locals {
  # This points to the folder in your current directory
  vendors_local_path = "${path.module}/staff_leave_system/vendors"

  mime_types = {
    # Document types
    "html" = "text/html"
    "css"  = "text/css"
    "js"   = "application/javascript"

    # Image types
    "png"  = "image/png"
    "jpg"  = "image/jpeg"
    "jpeg" = "image/jpeg"
    "gif"  = "image/gif"
    "svg"  = "image/svg+xml"
    "ico"  = "image/x-icon"
    "webp" = "image/webp"

    # Font types (common in vendor folders e.g. FontAwesome, Bootstrap)
    "woff"  = "font/woff"
    "woff2" = "font/woff2"
    "ttf"   = "font/ttf"
    "otf"   = "font/otf"
    "eot"   = "application/vnd.ms-fontobject"

    # Data types
    "json" = "application/json"
    "map"  = "application/json" # JS source maps
    "xml"  = "application/xml"
    "txt"  = "text/plain"
  }
}

# 1. Create the bucket with a UNIQUE name
resource "aws_s3_bucket" "vendors_bucket" {
  bucket        = "sui-vendors"
  force_destroy = true
}

# 2. Block all public access (Safety first)
resource "aws_s3_bucket_public_access_block" "vendors_block" {
  bucket = aws_s3_bucket.vendors_bucket.id

  # Explicit dependency ensures bucket exists before applying block
  depends_on = [aws_s3_bucket.vendors_bucket]

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 3. Sync local files to S3
#    depends_on ensures:
#    - public access is blocked BEFORE files are uploaded
#    - bucket policy is applied BEFORE files are uploaded
resource "aws_s3_object" "vendors_files" {
  depends_on = [
    aws_s3_bucket_public_access_block.vendors_block,
    aws_s3_bucket_policy.cloudfront_access
  ]

  for_each = fileset(local.vendors_local_path, "**/*")

  bucket = aws_s3_bucket.vendors_bucket.id

  # IMPORTANT: This ensures the path in S3 is "vendors/..."
  # so CloudFront routing matches your PHP code paths exactly.
  key    = "vendors/${each.value}"
  source = "${local.vendors_local_path}/${each.value}"

  # Look up MIME type by file extension, fallback to binary stream
  content_type = lookup(
    local.mime_types,
    lower(element(split(".", each.value), length(split(".", each.value)) - 1)),
    "application/octet-stream"
  )

  cache_control = "public, max-age=31536000, immutable"

  # Re-upload file if its content changes
  etag = filemd5("${local.vendors_local_path}/${each.value}")
}

# Output the CloudFront friendly domain
output "s3_bucket_domain" {
  description = "Use this in your CloudFront Origin domain_name"
  value       = aws_s3_bucket.vendors_bucket.bucket_regional_domain_name
}

output "s3_bucket_arn" {
  description = "Use this to reference the bucket ARN in IAM policies"
  value       = aws_s3_bucket.vendors_bucket.arn
}
