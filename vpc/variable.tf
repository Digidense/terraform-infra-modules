variable "region" {
  description = "create vpc cider value"
  type        = string
}

variable "vpc_cider" {
  description = "create vpc cider value"
  type        = string
}

variable "vpc-tag" {
  description = "The  name of vpc"
  type = object({
    Name        = string
    Environment = string
  })
  default = ({
    Name        = "Digi_VPC"
    Environment = "Dev"
  })
}

variable "az" {
  description = "availability zone"
  type        = list(string)
 default     = ["us-east-1a", "us-east-1b"]
}
variable "public_subnet" {
  description = "create public subnet"
  type        = list(string)
 default     = ["192.168.0.0/26", "192.168.0.64/26"]
}

variable "public_subnet_tag" {
  description = "The tags for the public subnets"
  type = list(object({
    Name        = string
    Environment = string
  }))
  default = [
    {
      Name        = "pub01"
      Environment = "Dev"
    },
    {
      Name        = "pub02"
      Environment = "Dev"
    }
  ]
}

variable "private_subnet" {
  description = "create public subnet"
  type        = list(string)
 default     = ["192.168.0.128/26", "192.168.0.192/26"]
}

variable "private_subnet_tag" {
  description = "The tags for the private subnets"
  type = list(object({
    Name        = string
    Environment = string
  }))
  default = [
    {
      Name        = "private_01"
      Environment = "Dev"
    },
    {
      Name        = "private_02"
      Environment = "Dev"
    }
  ]
}

variable "igw-tag" {
  description = "The  name of vpc"
  type = object({
    Name        = string
    Environment = string
  })
  default = ({
    Name        = "Digi_IGW"
    Environment = "Dev"
  })
}

variable "public_route-tag" {
  description = "The  name of vpc"
  type = object({
    Name        = string
    Environment = string
  })
  default = ({
    Name        = "Digi_public_rt"
    Environment = "Dev"
  })
}

variable "private_route-tag" {
  description = "The  name of vpc"
  type = object({
    Name        = string
    Environment = string
  })
  default = ({
    Name        = "Digi_private_rt"
    Environment = "Dev"
  })
}

variable "Endpoint_service_name" {
  description = "create service name"
  type        = list(string)
  default     = ["com.amazonaws.us-east-1.s3", "com.amazonaws.us-east-1.dynamodb"]
}

variable "endpoint" {
  description = "The tags for the private subnets"
  type = list(object({
    Name        = string
    Environment = string
  }))
  default = [
    {
      Name        = "S3_Endpoint"
      Environment = "Dev"
    },
    {
      Name        = "DynamoDB_endpoint"
      Environment = "Dev"
    }
  ]
}

variable "sg_port" {
  description = "Port traffic enable"
  type        = list(string)
  default     = [22, 80, 443, 11211]
}

variable "sg-tag" {
  description = "The  name of vpc"
  type = object({
    Name        = string
    Environment = string
  })
  default = ({
    Name        = "Digi_Network"
    Environment = "Dev"
  })
}