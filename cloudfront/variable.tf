variable "aws_region" {
  description = "AWS Region"
  type = string
  default = "us-east-1"
}

variable "bucket_name" {
  description = "Name of the bucket"
  type = string
  default = "mybucket-app-demo"
}

variable "scope" {
  description = "Scope of the WAF Web ACL (REGIONAL or CLOUDFRONT)"
  type        = string
  default     = "CLOUDFRONT"
}

variable "web_acl_name" {
  description = "Name of the WAF Web ACL"
  type        = string
  default     = "cloud-web-acl"
}

variable "web_acl_description" {
  description = "Description of the WAF Web ACL"
  type        = string
  default     = "Cloud Web ACL for managing WAF rules"
}

variable "web_acl_metric_name" {
  description = "Metric name for CloudWatch visibility for the Web ACL"
  type        = string
  default     = "CloudWebACL"
}