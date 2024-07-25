output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.digi-network.id
}

# Outputs for each public subnet
output "public_subnet_01" {
  description = "The ID of the first public subnet"
  value       = aws_subnet.pub01[0].id
}

output "public_subnet_02" {
  description = "The ID of the second public subnet"
  value       = aws_subnet.pub01[1].id
}

# Outputs for each private subnet
output "private_subnet_01" {
  description = "The ID of the first private subnet"
  value       = aws_subnet.pri01[0].id
}

output "private_subnet_02" {
  description = "The ID of the second private subnet"
  value       = aws_subnet.pri01[1].id
}
