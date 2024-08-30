variable "region" {
  description = "This block is for region reference"
  type = string
  default = "us-east-1"
}

variable "type_zip" {
  description = "This block is for zip_type reference"
  type = string
  default = "zip"
}

variable "lambda_role" {
  description = "This block is for lambda_role reference"
  type = string
  default = "lambda_role"
}

variable "auth_name" {
  description = "This block is for auth_name reference"
  type = string
  default = "API_Authorizer"
}

variable "api_gateway_authorizer" {
  description = "This block is for api_gateway_authorizer reference"
  type = string
  default = "API_Gateway_Authorizer"
}

variable "LambdaFunction_api" {
  description = "This block is for LambdaFunction_api reference"
  type = string
  default = "LambdaFunction_api"
}

variable "tag" {
  description = "This block is for tag reference"
  type = string
  default = "YOUR API CONFIGURATION IA WORKING !!!!!!!! "
}

variable "api_name" {
  description = "This block is for api_name reference"
  type = string
  default = "Flash_API_Gateway"
}

variable "path-name" {
  description = "Enter the path of your API_Gateway"
  type = string
}

variable "method" {
  description = "This block is for method reference"
  type = string
}

variable "Stage_name" {
  description = "This block is for method reference"
  type = string
}