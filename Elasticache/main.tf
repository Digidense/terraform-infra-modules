resource "aws_elasticache_replication_group" "elastic_cache" {
  count = var.cache_provider == var.cache_provider && var.cache_engine == var.cache_engine ? 1 : 0

  replication_group_id          = var.cluster_id
  description                   = var.elasticache
  engine                        = var.cache_engine
  node_type                     = var.instance_type
  num_node_groups               = 1
  replicas_per_node_group       = var.num_cache_nodes - 1
  multi_az_enabled              = var.multi_az
  automatic_failover_enabled    = var.multi_az
  at_rest_encryption_enabled    = true
  transit_encryption_enabled    = true

  tags = {
    Name = var.elasticache
  }
}

resource "aws_elasticache_cluster" "elasticache_cluster" {
  count = var.cache_provider == var.cache_provider && var.cache_engine == "memcached" ? 1 : 0

  cluster_id           = var.cluster_id
  engine               = var.cache_engine
  node_type            = var.instance_type
  num_cache_nodes      = var.num_cache_nodes
  az_mode              = var.multi_az ? "cross-az" : "single-az"
  parameter_group_name = "default.memcached1.4"
  port                 = 11211

  tags = {
    Name = var.elasticache-cluster
  }
}
