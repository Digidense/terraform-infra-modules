# Output for Invoke_url
output "invoke_url" {
  value = aws_api_gateway_deployment.api_deployment.invoke_url
}

# Output the ARN of the Lambda function for the API Gateway authorizer
output "authorizer_lambda_function_arn" {
  value = aws_lambda_function.authorizer.arn
  description = "The ARN of the Lambda function used as the API Gateway authorizer."
}

# Output the ARN of the Lambda function for the API
output "api_lambda_function_arn" {
  value = aws_lambda_function.api_lambda_function.arn
  description = "The ARN of the Lambda function used in the API Gateway."
}

# Output the API Gateway URL
output "api_gateway_url" {
  value = "https://${aws_api_gateway_rest_api.api_gateway.id}.execute-api.${var.region}.amazonaws.com/${var.Stage_name}"
  description = "The URL of the API Gateway endpoint."
}

# Output the ID of the API Gateway
output "api_gateway_id" {
  value = aws_api_gateway_rest_api.api_gateway.id
  description = "The ID of the API Gateway."
}

# Output the ID of the API Gateway authorizer
output "api_gateway_authorizer_id" {
  value = aws_api_gateway_authorizer.auth.id
  description = "The ID of the API Gateway authorizer."
}

# Output the ARN of the IAM role used by Lambda functions
output "lambda_role_arn" {
  value = aws_iam_role.lambda_role.arn
  description = "The ARN of the IAM role used by the Lambda functions."
}
