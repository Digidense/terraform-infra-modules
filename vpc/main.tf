provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_vpc_endpoint_service" "s3" {
  filter {
    name   = "service-name"
    values = ["com.amazonaws.${var.region}.s3"]
  }
  filter {
    name   = "service-type"
    values = ["Gateway"]
  }
}

data "aws_vpc_endpoint_service" "dynamodb" {
  filter {
    name   = "service-name"
    values = ["com.amazonaws.${var.region}.dynamodb"]
  }
  filter {
    name   = "service-type"
    values = ["Gateway"]
  }
}

locals {
  # Ensure count_num does not exceed the number of available availability zones
  effective_count_num = min(var.count_num, length(data.aws_availability_zones.available.names))
}

# Creating virtual  network
resource "aws_vpc" "digi-vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  instance_tenancy     = "default"
  tags                 = var.vpc-tag
}

# Creating virtual public network
resource "aws_subnet" "public" {
  count                   = local.effective_count_num
  vpc_id                  = aws_vpc.digi-vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 4, count.index)
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "digi-public-subnet-${count.index + 1}"
  }
}

# Creating virtual private network
resource "aws_subnet" "private" {
  count             = local.effective_count_num
  vpc_id            = aws_vpc.digi-vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 4, count.index + local.effective_count_num)
  availability_zone = element(data.aws_availability_zones.available.names, count.index)
  tags = {
    Name = "digi-private-subnet-${count.index + 1}"
  }
}

# Creating internet gatway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.digi-vpc.id
  tags   = var.igw_tag
}

# Creating public route table
resource "aws_route_table" "pub_rt" {
  vpc_id = aws_vpc.digi-vpc.id
  tags   = var.public_route_tag
}

# Creating private route table
resource "aws_route_table" "pri_rt" {
  vpc_id = aws_vpc.digi-vpc.id
  tags   = var.private_route_tag
}

# Creating route entry for igw
resource "aws_route" "route" {
  route_table_id         = aws_route_table.pub_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# Public rout table association
resource "aws_route_table_association" "pub_rt_01" {
  count          = local.effective_count_num
  route_table_id = aws_route_table.pub_rt.id
  subnet_id      = aws_subnet.public[count.index].id
}

# Private rout table association
resource "aws_route_table_association" "pri_rt_01" {
  count          = local.effective_count_num
  route_table_id = aws_route_table.pri_rt.id
  subnet_id      = aws_subnet.private[count.index].id
}

# Private endpoint for S3 and DynamoDB
resource "aws_vpc_endpoint" "s3_endpoint" {
  service_name      = data.aws_vpc_endpoint_service.s3.service_name
  vpc_id            = aws_vpc.digi-vpc.id
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.pri_rt.id]
  tags = {
    Name        = "S3_Endpoint"
    Environment = "Dev"
  }
}

# Private endpoint for  DynamoDB
resource "aws_vpc_endpoint" "dynamodb_endpoint" {
  service_name      = data.aws_vpc_endpoint_service.dynamodb.service_name
  vpc_id            = aws_vpc.digi-vpc.id
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.pri_rt.id]
  tags = {
    Name        = "DynamoDB_Endpoint"
    Environment = "Dev"
  }
}

# Creating security group
resource "aws_security_group" "sg" {
  name        = "Only allow ssh and http"
  description = "create the sg"
  vpc_id      = aws_vpc.digi-vpc.id
  dynamic "ingress" {
    for_each = var.sg_port
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port   = 0
    protocol    = "tcp"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = var.sg_tag
}
