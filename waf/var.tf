variable "aws_region" {
  description = "The AWS region to deploy the WAF and associated resources"
  type        = string
  default     = "us-east-1"
}

variable "scope" {
  description = "Scope of the WAF Web ACL (REGIONAL or CLOUDFRONT)"
  type        = string
  default     = "REGIONAL"
}

variable "ip_set_name" {
  description = "Name of the IP set"
  type        = string
  default     = "digidense-ip-set"
}

variable "ip_set_description" {
  description = "Description of the IP set"
  type        = string
  default     = "Digidense IP set for blocking specific IPs"
}

variable "blocked_ips" {
  description = "List of IP addresses or CIDR ranges to block"
  type        = list(string)
  default     = ["192.0.2.0/24", "198.51.100.0/24"] # Replace with actual IPs
}

variable "web_acl_name" {
  description = "Name of the WAF Web ACL"
  type        = string
  default     = "digidense-web-acl"
}

variable "web_acl_description" {
  description = "Description of the WAF Web ACL"
  type        = string
  default     = "Digidense Web ACL for managing WAF rules"
}

variable "web_acl_metric_name" {
  description = "Metric name for CloudWatch visibility for the Web ACL"
  type        = string
  default     = "digidenseWebACL"
}
