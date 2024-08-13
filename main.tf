# Create an IP set (optional, for blocking specific IPs)
resource "aws_wafv2_ip_set" "example" {
  name               = "examplennn-ip-set"
  description        = "Example IP set"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  addresses          = ["192.0.2.0/24"]
}

# Create a WAF Web ACL
resource "aws_wafv2_web_acl" "example" {
  name        = "example-web-acl"
  description = "Example Web ACL"
  scope       = "REGIONAL" # Use 'CLOUDFRONT' for CloudFront distributions

  default_action {
    allow {}
  }

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

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "exampleWebACL"
    sampled_requests_enabled   = true
  }
}

# Create an API Gateway REST API
resource "aws_api_gateway_rest_api" "example" {
  name = "example-api"
}

# Add a GET method to the root resource of the API Gateway
resource "aws_api_gateway_method" "root_get" {
  rest_api_id   = aws_api_gateway_rest_api.example.id
  resource_id   = aws_api_gateway_rest_api.example.root_resource_id
  http_method   = "GET"
  authorization = "NONE"
}

# Create a deployment for the API Gateway
resource "aws_api_gateway_deployment" "example" {
  rest_api_id = aws_api_gateway_rest_api.example.id

  # To force a new deployment on each change
  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.example))
  }

  # Depends on the method being created
  depends_on = [
    aws_api_gateway_method.root_get
  ]
}

# Create a stage for the API Gateway
resource "aws_api_gateway_stage" "example" {
  stage_name    = "prod"
  rest_api_id   = aws_api_gateway_rest_api.example.id
  deployment_id = aws_api_gateway_deployment.example.id
}

# Associate the WAF Web ACL with the API Gateway stage
resource "aws_wafv2_web_acl_association" "example" {
  resource_arn = "${aws_api_gateway_rest_api.example.execution_arn}/${aws_api_gateway_stage.example.stage_name}"
  web_acl_arn  = aws_wafv2_web_acl.example.arn
}
