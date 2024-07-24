output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.digi-network.id
}

output "public_subnet" {
  description = "The IDs of the public subnets"
  value       = tolist(aws_subnet.pub01[*].id)
}

output "private_subnet" {
  description = "The IDs of the private subnets"
  value       = tolist(aws_subnet.pri01[*].id)
}