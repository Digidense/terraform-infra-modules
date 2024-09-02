variable "region" {
  type = string
  default = "us-east-1"
}

variable "type_zip" {
  description = "This block is for zip_type reference"
  type        = string
  default     = "zip"
}

variable "lambda_role" {
  description = "This block is for lambda_role reference"
  type        = string
  default     = "lambda_role_api"
}

variable "auth_name" {
  description = "This block is for auth_name reference"
  type        = string
  default     = "API_Authorizer"
}

variable "api_gateway_authorizer" {
  description = "This block is for api_gateway_authorizer reference"
  type        = string
  default     = "API_Gateway_Authorizer"
}

variable "LambdaFunction_api" {
  description = "This block is for LambdaFunction_api reference"
  type        = string
  default     = "LambdaFunction_api"
}

variable "tag" {
  description = "This block is for tag reference"
  type        = string
  default     = "YOUR API CONFIGURATION IS WORKING !!!!!!!! "
}

variable "api_name" {
  description = "This block is for api_name reference"
  type        = string
  default     = "Flash_API_Gateway"
}

variable "path-name" {
  description = "The path component of the API Gateway resource, used to define the specific endpoint within the API."
  type        = string
  default     = "cart"
}

variable "method" {
  description = "The HTTP method (e.g., GET, POST, PUT, DELETE) that will be associated with the API Gateway method."
  type        = string
  default     = "GET"
}

variable "Stage_name" {
  description = "The name of the deployment stage for the API Gateway, typically used to differentiate between environments (e.g., dev, test, prod)."
  type        = string
  default     = "dev"
}
