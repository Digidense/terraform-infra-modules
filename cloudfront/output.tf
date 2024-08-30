output "website_url" {
  description = "My website URL"
  value = aws_s3_bucket_website_configuration.web-config.website_endpoint
}

output "distribution_domain_name" {
  description = "This is for distribution name"
  value = aws_cloudfront_distribution.cdn_distribution.domain_name
}

