# Reference the IDs of the elasticache
output "cache_endpoint" {
  value       = var.cache_engine == "memcached" && length(aws_elasticache_cluster.elasticache_cluster) > 0 ? aws_elasticache_cluster.elasticache_cluster[0].cache_nodes[0].address : ""
  description = "The endpoint of the Memcached cluster"
}

output "replication_group_id" {
  value       = var.cache_engine == "redis" && length(aws_elasticache_replication_group.elastic_cache) > 0 ? aws_elasticache_replication_group.elastic_cache[0].replication_group_id : null
  description = "The ID of the Redis replication group"
}


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

#output "security_group" {
#  description = "The IDs of the security group"
#  value = module.vpc_module.security_group
#}

# Reference the KMS Ids
output "kms_key_id" {
  description = "The ID of the KMS key"
  value       = aws_kms_key.elasticache_kms_key.id
}

output "kms_key_arn" {
  description = "The ID of the KMS key"
  value       = aws_kms_key.elasticache_kms_key.arn
}

