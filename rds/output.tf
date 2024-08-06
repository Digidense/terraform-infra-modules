# Reference the VPC ID from the vpc_module
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc_module.vpc_id
}

output "public_subnet" {
  description = "The IDs of the public subnets"
  value       = module.vpc_module.public_subnet
}

output "private_subnet" {
  description = "The IDs of the private subnets"
  value       = module.vpc_module.private_subnet
}

output "security_group" {
  description = "The IDs of the security group"
  value = module.vpc_module.sg
}

# Reference the KMS Ids
output "kms_key_id" {
  description = "The ID of the KMS key"
  value       = aws_kms_key.rds_kms_key.id
}

output "kms_key_arn" {
  description = "The ID of the KMS key"
  value       = aws_kms_key.rds_kms_key.arn
}