variable "api_name" {
  description = "The name of the API Gateway"
  type        = string
  default     = "Demo_API"
}

variable "stage_name" {
  description = "The deployment stage of the API"
  type        = string
  default     = "dev"
}

variable "token_authorizer_arn" {
  description = "The ARN of the Lambda authorizer function"
  type        = string
  default     = "arn:aws:lambda:us-east-1:123456789012:function:default-authorizer"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}
