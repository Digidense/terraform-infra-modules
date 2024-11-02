variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
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

variable "region" {
  description = "The AWS region to create resources in"
  type        = string
}

variable "count_num" {
  description = "Number of subnets"
  type        = number
}

variable "igw_tag" {
  description = "Tags for the internet gateway"
  type = object({
    Name        = string
    Environment = string
  })
  default = {
    Name        = "Digi_IGW"
    Environment = "Dev"
  }
}

variable "public_route_tag" {
  description = "Tags for the public route table"
  type = object({
    Name        = string
    Environment = string
  })
  default = {
    Name        = "Digi_public_rt"
    Environment = "Dev"
  }
}

variable "private_route_tag" {
  description = "Tags for the private route table"
  type = object({
    Name        = string
    Environment = string
  })
  default = {
    Name        = "Digi_private_rt"
    Environment = "Dev"
  }
}

variable "sg_port" {
  description = "Ports to allow in the security group"
  type        = list(number)
  default     = [22, 80, 443, 11211]
}

variable "sg_tag" {
  description = "Tags for the security group"
  type = object({
    Name        = string
    Environment = string
  })
  default = {
    Name        = "Digi_Network"
    Environment = "Dev"
  }
}
