resource "aws_s3_bucket_policy" "cloudfront_access" {
  bucket = aws_s3_bucket.vendors_bucket.id

  # Must wait for distribution to exist before referencing its ID
  depends_on = [aws_cloudfront_distribution.main]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipalReadOnly"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.vendors_bucket.arn}/*"
        Condition = {
          StringEquals = {
            # Scoped to THIS distribution only - no other CF can access bucket
            "AWS:SourceArn" = "arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${aws_cloudfront_distribution.main.id}"
          }
        }
      }
    ]
  })
}