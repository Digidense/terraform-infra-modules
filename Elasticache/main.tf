# Import VPC Module
module "vpc_module" {
  source = "git::https://github.com/Digidense/terraform-infra-modules.git//vpc?ref=feature/vpc_module"
  vpc_cidr = var.vpc_cidr
  region = var.region
  count_num = var.count_num
}

# Create a subnet group for ElastiCache
resource "aws_elasticache_subnet_group" "elasticache_subnet_group" {
  name       = "elasticache-subnet-group"
  description = "Subnet group for ElastiCache"
  subnet_ids = module.vpc_module.private_subnet
}

# Create KMS Key for Encryption
resource "aws_kms_key" "elasticache_kms_key" {
  description             = "KMS key for ElastiCache encryption"
  deletion_window_in_days = var.deletion_window_in_days
  enable_key_rotation = true

}

# Creates an AWS KMS alias name
resource "aws_kms_alias" "my_alias" {
  name          = var.aliases_name
  target_key_id = aws_kms_key.elasticache_kms_key.arn
}

# Elasticache Replication Group for Redis
resource "aws_elasticache_replication_group" "elastic_cache" {
  count = var.cache_engine == "redis" ? 1 : 0

  replication_group_id       = var.cluster_id
  description                = var.elasticache
  engine                     = var.cache_engine
  node_type                  = var.instance_type
  num_node_groups            = 1
  replicas_per_node_group    = var.num_cache_nodes
  multi_az_enabled           = var.multi_az
  automatic_failover_enabled = var.multi_az
  at_rest_encryption_enabled = true
  transit_encryption_enabled = true
  kms_key_id                 = aws_kms_key.elasticache_kms_key.arn
  subnet_group_name          = aws_elasticache_subnet_group.elasticache_subnet_group.name

  log_delivery_configuration {
    destination      = aws_cloudwatch_log_group.cache_logs.name
    destination_type = "cloudwatch-logs"
    log_format       = "text"
    log_type         = "engine-log"
  }

  tags = {
    Name = var.elasticache
  }

  lifecycle {
    ignore_changes = all
  }
}

# Elasticache Cluster for Memcached
resource "aws_elasticache_cluster" "elasticache_cluster" {
  count = var.cache_engine == "memcached" ? 1 : 0
  cluster_id           = var.cluster_id
  engine               = var.cache_engine
  node_type            = var.instance_type
  num_cache_nodes      = var.num_cache_nodes
  az_mode              = var.num_cache_nodes > 1 && var.multi_az ? "cross-az" : "single-az"
  parameter_group_name = aws_elasticache_parameter_group.elasticcache_parameter_group[0].name
  port                 = var.port_no
  subnet_group_name    = aws_elasticache_subnet_group.elasticache_subnet_group.name

  tags = {
    Name = var.elasticache
  }

  lifecycle {
    ignore_changes = all
  }
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "cache_logs" {
  name = "redis-slow-logs"
}

# Parameter Group for Memcached
resource "aws_elasticache_parameter_group" "elasticcache_parameter_group" {
  count       = var.cache_engine == "memcached" ? 1 : 0
  name        = "elasticache-pg"
  family      = "memcached1.6"
  description = "This block is for parameter group"
}

# Parameter Group for Redis
resource "aws_elasticache_parameter_group" "parameter_group" {
  count       = var.cache_engine == "redis" ? 1 : 0
  name        = "cache-params"
  family      = "redis6.x"
  description = "This block is for parameter group"

  parameter {
    name  = "activerehashing"
    value = "yes"
  }
}

# CloudWatch Alarm for ElastiCache CPU Utilization
locals {
  cache_id = var.cache_engine == "redis" ? aws_elasticache_replication_group.elastic_cache[0].id : aws_elasticache_cluster.elasticache_cluster[0].cluster_id
  metric_namespace = var.cache_engine == "redis" ? "ReplicationGroupId" : "CacheClusterId"
}

resource "aws_cloudwatch_metric_alarm" "elasticache_cpu_alarm" {
  alarm_name          = "ElasticacheCPUUtilizationHigh"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ElastiCache"
  period              = var.alarm_period
  statistic           = "Average"
  threshold           = var.alarm_threshold

  dimensions = {
    "${local.metric_namespace}" = local.cache_id
  }

  alarm_description = "Alarm when ElastiCache CPU utilization exceeds threshold"
  alarm_actions     = var.alarm_actions

  lifecycle {
    ignore_changes = all
  }

  depends_on = [
    aws_elasticache_replication_group.elastic_cache,
    aws_elasticache_cluster.elasticache_cluster
  ]
}
