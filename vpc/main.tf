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
    Name : "public ${count.index} "
  }
}

# Creating virtual private network
resource "aws_subnet" "pri01" {
  vpc_id            = aws_vpc.digi-network.id
  count             = length(var.private_subnet)
  cidr_block        = element(var.private_subnet, count.index)
  availability_zone = element(var.az, count.index)
  tags = {
    Name : "private ${count.index} "
  }
}

# Creating internet gatway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.digi-network.id
  tags = {
    Name = "Digi_IGW"
  }
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
  tags = {
    Name : "Digi_public_rt"
  }
}

# Creating private route table
resource "aws_route_table" "pri_rt" {
  vpc_id = aws_vpc.digi-network.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name : "Digi_Private_rt"
  }
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

#Create elastic ip address
resource "aws_eip" "Elastic_IPs" {
}

#create nat_gateway
resource "aws_nat_gateway" "nat_gateway" {
  subnet_id     = aws_subnet.pub01[0].id
  allocation_id = aws_eip.Elastic_IPs.id
  tags          = var.vpc-tag
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
  tags = {
    Name = "Digi_Network"
  }
}
