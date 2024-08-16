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
  value = module.vpc_module.security_group
}

# Output the selected instance ARN
output "selected_instance" {
  value = local.total_selected == 1 ? "Instance created" : "No instance created or multiple instances selected, which is not allowed"
}

output "mysql_database_arn" {
  value = length(aws_db_instance.mysql_instance) > 0 ? aws_db_instance.mysql_instance[0].arn : null
}

output "postgres_database_arn" {
  value = length(aws_db_instance.postgres_instance) > 0 ? aws_db_instance.postgres_instance[0].arn : null
}

output "mssql_database_arn" {
  value = length(aws_db_instance.mssql_instance) > 0 ? aws_db_instance.mssql_instance[0].arn : null
}