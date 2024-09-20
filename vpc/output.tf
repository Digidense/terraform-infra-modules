output "vpc_id" {
  value = aws_vpc.digi-network
}

output "subnet_public" {
  value = aws_subnet.pub01
}

output "subnet_private" {
  value = aws_subnet.pri01
}

output "security_group" {
  value = aws_security_group.sg
}
