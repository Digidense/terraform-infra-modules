# API Gateway REST API
resource "aws_api_gateway_rest_api" "api" {
  name = var.api_name
}

# API Gateway Resource
resource "aws_api_gateway_resource" "resource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = var.path
}

# IAM Role for Lambda Execution (created if auth_type is LAMBDA)
resource "aws_iam_role" "lambda_exec_role" {
  count = var.auth_type == "LAMBDA" ? 1 : 0

  name = "${var.lambda_function_name}-exec"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# Attach Basic Execution Policy to Lambda Role (created if auth_type is LAMBDA)
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  count = var.auth_type == "LAMBDA" ? 1 : 0

  role       = element(aws_iam_role.lambda_exec_role.*.name, 0)
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Attach Lambda Execute Policy (created if auth_type is LAMBDA)
resource "aws_iam_role_policy_attachment" "lambda_invoke_apigateway" {
  count = var.auth_type == "LAMBDA" ? 1 : 0

  role       = element(aws_iam_role.lambda_exec_role.*.name, 0)
  policy_arn = "arn:aws:iam::aws:policy/AWSLambdaExecute"
}

# Lambda Function (created if auth_type is LAMBDA)
resource "aws_lambda_function" "auth_lambda" {
  count = var.auth_type == "LAMBDA" ? 1 : 0

  filename         = var.lambda_function_code
  function_name    = var.lambda_function_name
  handler          = var.lambda_function_handler
  runtime          = var.lambda_function_runtime
  role             = element(aws_iam_role.lambda_exec_role.*.arn, 0)
  source_code_hash = filebase64sha256(var.lambda_function_code)
}

# Allow API Gateway to Invoke the Lambda Function (created if auth_type is LAMBDA)
resource "aws_lambda_permission" "apigw_invoke_lambda" {
  count         = var.auth_type == "LAMBDA" ? 1 : 0
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = element(aws_lambda_function.auth_lambda.*.function_name, 0)
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

# API Gateway Authorizer (Lambda Authorizer)
resource "aws_api_gateway_authorizer" "lambda_authorizer" {
  count = var.auth_type == "LAMBDA" ? 1 : 0

  name            = "${var.api_name}-authorizer"
  rest_api_id     = aws_api_gateway_rest_api.api.id
  authorizer_uri  = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${element(aws_lambda_function.auth_lambda.*.arn, 0)}/invocations"
  type            = "REQUEST"
}

# API Gateway Method (with Lambda Authorizer)
resource "aws_api_gateway_method" "methods" {
  count             = length(var.methods)
  rest_api_id       = aws_api_gateway_rest_api.api.id
  resource_id       = aws_api_gateway_resource.resource.id
  http_method       = var.methods[count.index]
  authorization     = var.auth_type == "IAM" ? "AWS_IAM" : "CUSTOM"
  authorizer_id     = var.auth_type == "LAMBDA" ? element(aws_api_gateway_authorizer.lambda_authorizer.*.id, 0) : null
  request_models = {
    "application/json" = "Empty"
  }
  depends_on = [aws_api_gateway_resource.resource]
}

# API Gateway Integration for IAM (created if auth_type is IAM)
resource "aws_api_gateway_integration" "iam_integration" {
  count                   = var.auth_type == "IAM" ? length(var.methods) : 0
  rest_api_id             = aws_api_gateway_method.methods[count.index].rest_api_id
  resource_id             = aws_api_gateway_method.methods[count.index].resource_id
  http_method             = aws_api_gateway_method.methods[count.index].http_method
  integration_http_method = "POST"
  type                    = "MOCK"

  uri = "http://httpbin.org/post"
}

# API Gateway Integration for Lambda (created if auth_type is LAMBDA)
resource "aws_api_gateway_integration" "lambda_integration" {
  count                   = var.auth_type == "LAMBDA" ? length(var.methods) : 0
  rest_api_id             = aws_api_gateway_method.methods[count.index].rest_api_id
  resource_id             = aws_api_gateway_method.methods[count.index].resource_id
  http_method             = aws_api_gateway_method.methods[count.index].http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"

  uri = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${element(aws_lambda_function.auth_lambda.*.arn, 0)}/invocations"

  depends_on = [
    aws_api_gateway_method.methods,
    aws_lambda_permission.apigw_invoke_lambda,
  ]
}

# API Gateway Deployment
resource "aws_api_gateway_deployment" "api_deployment" {
  depends_on = [
    aws_api_gateway_integration.iam_integration,
    aws_api_gateway_integration.lambda_integration,
  ]

  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = var.stage_name
}

# API Gateway Role (IAM)
resource "aws_iam_role" "api_gateway_role" {
  name = "APIGatewayInvokeRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "apigateway.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

# API Gateway Policy allowing invocation of Lambda and API Gateway methods
resource "aws_iam_role_policy" "api_gateway_policy" {
  role = aws_iam_role.api_gateway_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = [
        "lambda:InvokeFunction",
        "execute-api:Invoke"
      ],
      Resource = "*"
    }]
  })
}
