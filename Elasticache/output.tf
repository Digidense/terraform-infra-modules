output "cache_endpoint" {
  value       = length(aws_elasticache_cluster.elasticache_cluster) > 0 ? aws_elasticache_cluster.elasticache_cluster[0].cache_nodes[0].address : ""
  description = "The endpoint of the Memcached cluster"
}

output "replication_group_id" {
  value       = length(aws_elasticache_replication_group.elastic_cache) > 0 ? aws_elasticache_replication_group.elastic_cache[0].replication_group_id : ""
  description = "The ID of the Redis replication group"
}
