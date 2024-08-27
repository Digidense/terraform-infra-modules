output "api_id" {
  value = aws_api_gateway_rest_api.api.id
}

output "resource_id" {
  value = aws_api_gateway_resource.resource.id
}

output "lambda_function_arn" {
  value = var.auth_type == "LAMBDA" ? aws_lambda_function.auth_lambda[0].arn : null
  description = "The ARN of the Lambda function used for LAMBDA authentication, if applicable."
}

# Output the API Invoke URL
output "api_invoke_url" {
  value = "${aws_api_gateway_rest_api.api.execution_arn}/${var.stage_name}/${aws_api_gateway_resource.resource.path_part}"
  description = "The base URL for the API Gateway."
}