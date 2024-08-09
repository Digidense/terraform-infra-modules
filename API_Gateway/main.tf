# Creates the API Gateway with a specified name and description.
resource "aws_api_gateway_rest_api" "api" {
  name        = var.api_name
  description = "API Gateway for managing Cart endpoints"
}

# Creates the /cart resource within the API Gateway.
resource "aws_api_gateway_resource" "cart" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "cart"
}

# Defines the GET method for the /cart resource with custom authorization.
resource "aws_api_gateway_method" "get_cart" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.cart.id
  http_method   = "GET"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.token_authorizer.id
}

# Defines the PUT method for the /cart resource with custom authorization.
resource "aws_api_gateway_method" "put_cart" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.cart.id
  http_method   = "PUT"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.token_authorizer.id
}

# Defines the PATCH method for the /cart resource with custom authorization.
resource "aws_api_gateway_method" "patch_cart" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.cart.id
  http_method   = "PATCH"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.token_authorizer.id
}

# Creates a token authorizer that uses a Lambda function to authorize requests.
resource "aws_api_gateway_authorizer" "token_authorizer" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  name        = "token_authorizer"
  type        = "TOKEN"
  authorizer_uri = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${var.token_authorizer_arn}/invocations"
  identity_source = "method.request.header.Authorization"
}

# Sets up a MOCK integration for the GET method on the /cart resource.
resource "aws_api_gateway_integration" "get_cart_integration" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.cart.id
  http_method = aws_api_gateway_method.get_cart.http_method
  type        = "MOCK"
}

# Sets up a MOCK integration for the PUT method on the /cart resource.
resource "aws_api_gateway_integration" "put_cart_integration" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.cart.id
  http_method = aws_api_gateway_method.put_cart.http_method
  type        = "MOCK"
}

# Sets up a MOCK integration for the PATCH method on the /cart resource.
resource "aws_api_gateway_integration" "patch_cart_integration" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.cart.id
  http_method = aws_api_gateway_method.patch_cart.http_method
  type        = "MOCK"
}

# Deploys the API Gateway to a specified stage after all integrations are created.
resource "aws_api_gateway_deployment" "api_deployment" {
  depends_on = [
    aws_api_gateway_integration.get_cart_integration,
    aws_api_gateway_integration.put_cart_integration,
    aws_api_gateway_integration.patch_cart_integration
  ]

  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = var.stage_name
}
