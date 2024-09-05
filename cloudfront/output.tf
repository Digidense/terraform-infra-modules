output "website_url" {
  description = "My website URL"
  value = aws_s3_bucket_website_configuration.web-config.website_endpoint
}

output "distribution_domain_name" {
  description = "This is for distribution name"
  value = aws_cloudfront_distribution.cdn_distribution.domain_name
}

# output from the WAF module
output "waf_acl_id" {
  description = "The ARN of the WAF Web ACL from the waf_module"
  value       = module.waf_module.waf_acl_id
}

