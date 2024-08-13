# Outputs
output "web_acl_id" {
  value = aws_wafv2_web_acl.example.id
}

output "api_gateway_id" {
  value = aws_api_gateway_rest_api.example.id
}

output "api_gateway_stage" {
  value = aws_api_gateway_stage.example.stage_name
}

output "api_gateway_arn" {
  value = aws_api_gateway_rest_api.example.execution_arn
}
