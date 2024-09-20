variable "vpc_cider" {
  description = "create vpc cider value"
  type        = string
  default     = "192.168.0.0/24"
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

variable "public_subnet-tag" {
  description = "The  name of vpc"
  type = object({
    Name        = list(string)
    Environment = list(string)
  })
  default = ({
    Name        = ["pub01", "pub02"]
    Environment = ["Dev", "Dev"]
  })
}

variable "private_subnet" {
  description = "create public subnet"
  type        = list(string)
  default     = ["192.168.0.128/26", "192.168.0.192/26"]
}


variable "sg_port" {
  description = "Port traffic enable"
  type        = list(string)
  default     = [22, 80, 443, 11211, 80, 8080]
}
