provider "aws" {
  region = var.aws_region
}

# Create an IP set for blocking specific IPs
resource "aws_wafv2_ip_set" "digidense_ip_set" {
  name               = var.ip_set_name
  description        = var.ip_set_description
  scope              = var.scope
  ip_address_version = "IPV4"
  addresses          = var.blocked_ips
}

# Create a WAF Web ACL
resource "aws_wafv2_web_acl" "web_acl" {
  name        = var.web_acl_name
  description = var.web_acl_description
  scope       = var.scope

  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = var.web_acl_metric_name
    sampled_requests_enabled   = true
  }

  # Rule for AWS Managed Rules Common Rule Set
  rule {
    name     = "AWS-AWSManagedRulesCommonRuleSet"
    priority = 1

    statement {
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesCommonRuleSet"
      }
    }

    override_action {
      none {}
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "awsManagedCommonRules"
      sampled_requests_enabled   = true
    }
  }

  # Rule for Amazon IP Reputation List Managed Rule Group
  rule {
    name     = "AWS-AWSManagedRulesAmazonIpReputationList"
    priority = 2

    statement {
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesAmazonIpReputationList"
      }
    }

    override_action {
      none {}
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "amazonIpReputation"
      sampled_requests_enabled   = true
    }
  }

  # Rule for AWS Managed Rules Known Bad Inputs
  rule {
    name     = "AWS-AWSManagedRulesKnownBadInputsRuleSet"
    priority = 3

    statement {
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
      }
    }

    override_action {
      none {}
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesKnownBadInputsRuleSet"
      sampled_requests_enabled   = true
    }
  }

  # Rule to block specific IPs using the IP set
  rule {
    name     = "BlockSpecificIPs"
    priority = 4

    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.digidense_ip_set.arn
      }
    }

    action {
      block {}
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "blockSpecificIPs"
      sampled_requests_enabled   = true
    }
  }

  # Additional rules can be added here for further protection
}





