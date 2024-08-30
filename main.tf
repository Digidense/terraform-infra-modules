# AWS S3 bucket resource
resource "aws_s3_bucket" "test_bucket" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_ownership_controls" "example1" {
  bucket = aws_s3_bucket.test_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.test_bucket.id

  block_public_acls      = false
  block_public_policy    = false
  ignore_public_acls     = false
  restrict_public_buckets = false
}

# AWS S3 bucket ACL resource
resource "aws_s3_bucket_acl" "acl" {
  depends_on = [
    aws_s3_bucket_ownership_controls.example1,
    aws_s3_bucket_public_access_block.public_access,
  ]

  bucket = aws_s3_bucket.test_bucket.id
  acl    = "public-read"
}

# S3 bucket policy for public read access
resource "aws_s3_bucket_policy" "policy" {
  bucket = aws_s3_bucket.test_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action   = "s3:GetObject"
        Resource = "arn:aws:s3:::${aws_s3_bucket.test_bucket.id}/*"
      }
    ]
  })
}

resource "aws_s3_bucket_website_configuration" "web-config" {
  bucket = aws_s3_bucket.test_bucket.id

  # Configuration for the index document
  index_document {
    suffix = "sample.html"
  }
}

# Upload the HTML file directly
resource "aws_s3_object" "sample_html" {
  bucket       = aws_s3_bucket.test_bucket.id
  key          = "sample.html"
  source       = "C:/Users/admin/IdeaProjects/cloud_front/web_hosting_file/sample.html"
  acl          = "public-read"
  content_type = "text/html"
}

# Create a CloudFront Origin Access Identity (OAI) for S3 bucket access
resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "OAI for S3 bucket"
}

# Create a WAFv2 Web ACL
resource "aws_wafv2_web_acl" "waf_name" {
  name        = "sample-web-acl"
  description = "Web ACL for CloudFront"
  scope       = "CLOUDFRONT"
  default_action {
    allow {}
  }

  rule {
    name     = "example-rule"
    priority = 1

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    override_action {
      none {}
    }

    visibility_config {
      sampled_requests_enabled = true
      cloudwatch_metrics_enabled = true
      metric_name = "s3-waf-rule"
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "example-web-acl"
    sampled_requests_enabled   = true
  }
}

# Create a CloudFront distribution
resource "aws_cloudfront_distribution" "cdn_distribution" {
  origin {
    domain_name = aws_s3_bucket.test_bucket.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.test_bucket.id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "sample.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.test_bucket.id

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "PriceClass_100"

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # Associate the WAF Web ACL with the CloudFront distribution
  web_acl_id = aws_wafv2_web_acl.waf_name.arn
}
