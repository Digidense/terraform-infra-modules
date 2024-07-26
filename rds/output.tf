output "vpc_id" {
  value = module.vpc_module_rds.vpc_id
}

output "subnet_pri01_id" {
  value = module.vpc_module_rds.subnet_pri01
}

output "subnet_pri02_id" {
  value = module.vpc_module_rds.subnet_pri02
}

output "security_group_id" {
  value = module.vpc_module_rds.security_group_id
}

output "db_endpoint" {
  value = aws_db_instance.example.endpoint
}