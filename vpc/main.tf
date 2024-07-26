provider "aws" {
  region = var.region
}

# Creating virtual  network
resource "aws_vpc" "digi-network" {
  cidr_block           = var.vpc_cider
  enable_dns_hostnames = true
  instance_tenancy     = "default"
  tags                 = var.vpc-tag
}

# Creating virtual public network
resource "aws_subnet" "pub01" {
  vpc_id                  = aws_vpc.digi-network.id
  count                   = length(var.public_subnet)
  cidr_block              = element(var.public_subnet, count.index)
  map_public_ip_on_launch = true
  availability_zone       = element(var.az, count.index)
  tags = {
    Name        = var.public_subnet_tag[count.index].Name
    Environment = var.public_subnet_tag[count.index].Environment
  }
}

# Creating virtual private network
resource "aws_subnet" "pri01" {
  vpc_id            = aws_vpc.digi-network.id
  count             = length(var.private_subnet)
  cidr_block        = element(var.private_subnet, count.index)
  availability_zone = element(var.az, count.index)
  tags = {
    Name        = var.private_subnet_tag[count.index].Name
    Environment = var.private_subnet_tag[count.index].Environment
  }
}

# Creating internet gatway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.digi-network.id
  tags   = var.igw-tag
}

# Creating route entry for igw
resource "aws_route" "route" {
  route_table_id         = aws_route_table.pub_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# Creating public route table
resource "aws_route_table" "pub_rt" {
  vpc_id = aws_vpc.digi-network.id
  tags   = var.public_route-tag
}

# Creating private route table
resource "aws_route_table" "pri_rt" {
  vpc_id = aws_vpc.digi-network.id
  tags   = var.private_route-tag
}

# Public rout table association
resource "aws_route_table_association" "pub_rt_01" {
  count          = length(var.public_subnet)
  route_table_id = aws_route_table.pub_rt.id
  subnet_id      = aws_subnet.pub01[count.index].id
}

# Private rout table association
resource "aws_route_table_association" "pri_rt_01" {
  count          = length(var.private_subnet)
  route_table_id = aws_route_table.pri_rt.id
  subnet_id      = aws_subnet.pri01[count.index].id
}

# Private link for S3 and DynamoDB
resource "aws_vpc_endpoint" "s3_endpoint" {
  count             = 2
  service_name      = element(var.Endpoint_service_name, count.index)
  vpc_id            = aws_vpc.digi-network.id
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.pri_rt.id]
  tags = {
    Name        = var.endpoint[count.index].Name
    Environment = var.endpoint[count.index].Environment
  }
}

# Creating security group
resource "aws_security_group" "sg" {
  name        = "Only allow ssh and http"
  description = "create the sg"
  vpc_id      = aws_vpc.digi-network.id
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
  tags = var.sg-tag
}

