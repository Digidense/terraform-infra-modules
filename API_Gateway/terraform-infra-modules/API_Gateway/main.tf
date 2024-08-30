# Create ZIP archive for Lambda function (auth.py)
data "archive_file" "lambda_zip_auth" {
  type        = var.type_zip
  source_file = "lambda/auth.py"
  output_path = "lambda/auth.zip"
}

# Create ZIP archive for Lambda function (index.js)
data "archive_file" "lambda_zip_file" {
  type        = var.type_zip
  source_file = "lambda/index.js"
  output_path = "lambda/index.zip"
}

# Define IAM role for Lambda function
resource "aws_iam_role" "lambda_role" {
  name               = var.lambda_role
  assume_role_policy = file("lambda-policy.json")
}

# Attach basic execution policy to Lambda role
resource "aws_iam_role_policy_attachment" "lambda_exec_role_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Create API Gateway authorizer
resource "aws_api_gateway_authorizer" "auth" {
  name                        = var.auth_name
  rest_api_id                 = aws_api_gateway_rest_api.api_gateway.id
  authorizer_uri              = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.authorizer.arn}/invocations"
  authorizer_result_ttl_in_seconds = 300
  identity_source             = "method.request.header.Authorization"
  type                        = "TOKEN"
}

# Grant API Gateway permission to invoke Lambda authorizer
resource "aws_lambda_permission" "auth_permission" {
  statement_id  = "AllowAPIGatewayInvokeAuthorizer"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.authorizer.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway.execution_arn}/*/*"
}

# Define Lambda function for API Gateway authorizer
resource "aws_lambda_function" "authorizer" {
  filename         = "lambda/auth.zip"
  function_name    = var.api_gateway_authorizer
  role             = aws_iam_role.lambda_role.arn
  handler          = "auth.lambda_handler"
  runtime          = "python3.9"
  timeout          = 30
  source_code_hash = data.archive_file.lambda_zip_auth.output_base64sha256
}

# Define Lambda function for the API
resource "aws_lambda_function" "api_lambda_function" {
  filename         = "lambda/index.zip"
  function_name    = var.LambdaFunction_api
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  timeout          = 30
  source_code_hash = data.archive_file.lambda_zip_file.output_base64sha256

  environment {
    variables = {
      VIDEO_NAME = var.tag
    }
  }
}

# Create API Gateway
resource "aws_api_gateway_rest_api" "api_gateway" {
  name        = var.api_name
  description = "API_Gateway is creating"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# Define API Gateway resource
resource "aws_api_gateway_resource" "api_resource" {
  parent_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  path_part   = var.path-name
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
}

# Create API Gateway method
resource "aws_api_gateway_method" "method" {
  resource_id   = aws_api_gateway_resource.api_resource.id
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  http_method   = var.method
  authorization = "AWS_IAM"
  authorizer_id = aws_api_gateway_authorizer.auth.id
}

# Integrate API Gateway with Lambda function
resource "aws_api_gateway_integration" "lambda_integration" {
  http_method             = aws_api_gateway_method.method.http_method
  resource_id             = aws_api_gateway_resource.api_resource.id
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.api_lambda_function.invoke_arn
}

# Deploy API Gateway
resource "aws_api_gateway_deployment" "api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  stage_name  = var.Stage_name

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.api_resource.id,
      aws_api_gateway_method.method.id,
      aws_api_gateway_integration.lambda_integration.id
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_integration.lambda_integration
  ]
}

# Grant API Gateway permission to invoke Lambda function
resource "aws_lambda_permission" "apigw_lambda_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api_lambda_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway.execution_arn}/*/*/*"
}
