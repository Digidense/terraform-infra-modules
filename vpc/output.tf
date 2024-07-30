output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.digi-vpc.id
}

# Outputs for each public subnet
output "public_subnet" {
  description = "The IDs of the public subnets"
  value       = tolist(aws_subnet.public[*].id)
}

# Outputs for each private subnet
output "private_subnet" {
  description = "The IDs of the private subnets"
  value       = tolist(aws_subnet.private[*].id)
}