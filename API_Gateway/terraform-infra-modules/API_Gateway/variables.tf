variable "region" {
  description = "This block is for region reference"
  type        = string
  default     = "us-east-2"
}

variable "api_name" {
  description = "The name of the API Gateway"
  type        = string
  default     = "Demo_API_Gateway"
}

variable "methods" {
  description = "A list of HTTP methods to create for the API"
  type        = list(string)
}

variable "path" {
  type        = string
  description = "This block is for path reference"
}


variable "auth_type" {
  description = "The type of authentication to use (IAM or LAMBDA)"
  type        = string
}

variable "lambda_function_name" {
  description = "The name of the Lambda function for LAMBDA authentication"
  type        = string
  default     = "demo_lambda_api"
}

variable "lambda_function_handler" {
  description = "The handler for the Lambda function"
  type        = string
  default     = "index.handler"
}

variable "lambda_function_runtime" {
  description = "The runtime for the Lambda function"
  type        = string
  default     = "nodejs18.x"
}

variable "lambda_function_code" {
  description = "Path to the Lambda function code"
  type        = string
  default     = "example_lambda.zip"
}

variable "stage_name" {
  description = "The name of the stage (e.g., dev, staging, prod)"
  default     = "development"
}
