# AWS WAF and IP Blocking Terraform Configuration

This Terraform configuration sets up an AWS Web Application Firewall (WAF) to secure your applications from common web exploits and block specific IP addresses.

## Overview

This project provisions the following AWS resources:
- **IP Set**: Blocks specific IP addresses.
- **Web ACL**: Manages security rules for web traffic.
- **AWS Managed Rules**: Protects your application from common security vulnerabilities.

### Resources
- **aws_wafv2_ip_set**: A set of IP addresses or CIDR ranges that will be blocked from accessing your application.
- **aws_wafv2_web_acl**: A Web ACL that applies various security rules to incoming web traffic.

### Rules
1. **AWSManagedRulesCommonRuleSet**: Protects against common security issues (e.g., SQL injection, XSS attacks).
2. **AWSManagedRulesAmazonIpReputationList**: Blocks requests from known malicious IP addresses.
3. **BlockSpecificIPs**: Custom rule that blocks IP addresses specified in the `blocked_ips` variable.

## Variables

| Variable Name             | Description                                                                 | Default Value             |
| ------------------------- | --------------------------------------------------------------------------- | ------------------------- |
| `aws_region`              | The AWS region where the WAF and associated resources will be deployed.      | `us-east-1`               |
| `scope`                   | The scope of the WAF Web ACL, either `REGIONAL` or `CLOUDFRONT`.             | `REGIONAL`                |
| `ip_set_name`             | The name of the IP set to block specific IPs.                                | `digidense-ip-set`        |
| `ip_set_description`      | A description for the IP set.                                                | `Digidense IP set for blocking specific IPs` |
| `blocked_ips`             | A list of IP addresses or CIDR ranges to block.                              | `["192.0.2.0/24", "198.51.100.0/24"]` (replace with actual IPs) |
| `web_acl_name`            | The name of the Web ACL.                                                     | `digidense-web-acl`       |
| `web_acl_description`     | A description for the Web ACL.                                               | `Digidense Web ACL for managing WAF rules` |
| `web_acl_metric_name`     | The metric name used for CloudWatch visibility for the Web ACL.              | `digidenseWebACL`         |


