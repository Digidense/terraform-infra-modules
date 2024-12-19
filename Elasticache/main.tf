# Import VPC Module
module "vpc_module" {
  source    = "git::https://github.com/Digidense/terraform-infra-modules.git//vpc?ref=feature/vpc_module"
  vpc_cidr  = var.vpc_cidr
  region    = var.region
  count_num = var.count_num
}

# Create a subnet group for ElastiCache
resource "aws_elasticache_subnet_group" "elasticache_subnet_group" {
  name        = var.elasticache_subnet_group
  description = "Subnet group for ElastiCache"
  subnet_ids  = module.vpc_module.private_subnet

  tags = {
    Name        = var.elasticache_subnet_group
    Environment = var.environment
  }
}

# Get the current AWS account ID
data "aws_caller_identity" "current" {}

# Define the policy for the KMS key
data "aws_iam_policy_document" "kms_policy" {
  statement {
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = ["arn:aws:kms:${var.region}:${data.aws_caller_identity.current.account_id}:key/${aws_kms_key.elasticache_kms_key.key_id}"]

    principals {
      type        = "Service"
      identifiers = ["elasticache.amazonaws.com"]
    }

    effect = "Allow"
  }

  statement {
    actions = [
      "kms:Create*",
      "kms:Describe*",
      "kms:Enable*",
      "kms:List*",
      "kms:Put*",
      "kms:Update*",
      "kms:Revoke*",
      "kms:Disable*",
      "kms:Get*",
      "kms:Delete*",
      "kms:ScheduleKeyDeletion",
      "kms:CancelKeyDeletion"
    ]
    resources = ["arn:aws:kms:${var.region}:${data.aws_caller_identity.current.account_id}:key/${aws_kms_key.elasticache_kms_key.key_id}"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    effect = "Allow"
  }

  statement {
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = ["arn:aws:kms:${var.region}:${data.aws_caller_identity.current.account_id}:key/${aws_kms_key.elasticache_kms_key.key_id}"]

    principals {
      type        = "Service"
      identifiers = ["logs.amazonaws.com"]
    }

    effect = "Allow"
  }
}


# Create KMS Key for Encryption without policy
resource "aws_kms_key" "elasticache_kms_key" {
  description             = "KMS key for ElastiCache encryption"
  deletion_window_in_days = var.deletion_window_in_days
  enable_key_rotation     = true

  tags = {
    Name        = var.ElastiCacheKMSKey
    Environment = var.environment
  }
}

resource "aws_kms_key_policy" "default" {
  key_id = aws_kms_key.elasticache_kms_key.id
  policy = data.aws_iam_policy_document.kms_policy.json
}

# Creates an AWS KMS alias name
resource "aws_kms_alias" "my_alias" {
  name          = var.aliases_name
  target_key_id = aws_kms_key.elasticache_kms_key.arn
}

# ElastiCache Replication Group for Redis
resource "aws_elasticache_replication_group" "elastic_cache" {
  count = var.cache_engine == "redis" ? 1 : 0

  replication_group_id       = var.cluster_name
  description                = var.elasticache
  engine                     = var.cache_engine
  node_type                  = var.instance_type
  num_node_groups            = var.num_node_groups
  replicas_per_node_group    = var.num_cache_nodes
  multi_az_enabled           = var.multi_az
  automatic_failover_enabled = var.multi_az
  at_rest_encryption_enabled = true
  transit_encryption_enabled = true
  kms_key_id                 = aws_kms_key.elasticache_kms_key.arn
  subnet_group_name          = aws_elasticache_subnet_group.elasticache_subnet_group.name
  log_delivery_configuration {
    destination      = aws_cloudwatch_log_group.cache_logs.name
    destination_type = var.cloudwatch_logs
    log_format       = var.logs_formates
    log_type         = var.log_type
  }

  tags = {
    Name        = var.elasticache
    Environment = var.environment
  }

  lifecycle {
    ignore_changes = all
  }
}

# ElastiCache Cluster for Memcached
resource "aws_elasticache_cluster" "elasticache_cluster" {
  count = var.cache_engine == "memcached" ? 1 : 0

  cluster_id           = var.cluster_name
  engine               = var.cache_engine
  node_type            = var.instance_type
  num_cache_nodes      = var.num_cache_nodes
  az_mode              = var.az_mode
  parameter_group_name = aws_elasticache_parameter_group.elasticcache_parameter_group[0].name
  port                 = var.port_no
  subnet_group_name    = aws_elasticache_subnet_group.elasticache_subnet_group.name

  tags = {
    Name        = var.elasticache
    Environment = var.environment
  }

  lifecycle {
    ignore_changes = all
  }
}

resource "aws_iam_role_policy" "cloudwatch_logs_policy" {
  name   = "CloudWatchLogsPolicy"
  role   = aws_iam_role.elasticache_role.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "kms:Decrypt",
          "kms:Encrypt"
        ]
        Resource = aws_kms_key.elasticache_kms_key.arn
      }
    ]
  })
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "cache_logs" {
  name = var.cache_logs_name
  kms_key_id                 = aws_kms_key.elasticache_kms_key.arn
  tags = {
    Name        = var.cache_logs_name
    Environment = var.environment
  }
}

# Parameter Group for Memcached
resource "aws_elasticache_parameter_group" "elasticcache_parameter_group" {
  count       = var.cache_engine == "memcached" ? 1 : 0
  name        = var.elasticache_pg_memcached
  family      = var.pg_family_memcached
  description = "This block is for memcached parameter group"

  tags = {
    Name        = var.elasticache_pg_memcached
    Environment = var.environment
  }
}

# Parameter Group for Redis
resource "aws_elasticache_parameter_group" "parameter_group" {
  count       = var.cache_engine == "redis" ? 1 : 0
  name        = var.elasticache_pg_redis
  family      = var.pg_family_redis
  description = "This block is for redis parameter group"

  parameter {
    name  = var.parameter_name
    value = "yes"
  }

  tags = {
    Name        = var.elasticache_pg_redis
    Environment = var.environment
  }
}

# CloudWatch Alarm for ElastiCache CPU Utilization
locals {
  cache_id         = var.cache_engine == "redis" ? aws_elasticache_replication_group.elastic_cache[0].id : aws_elasticache_cluster.elasticache_cluster[0].cluster_id
  metric_namespace = var.cache_engine == "redis" ? "ReplicationGroupId" : "CacheClusterId"
}

resource "aws_cloudwatch_metric_alarm" "elasticache_cpu_alarm" {
  alarm_name          = var.alarm_name
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

  tags = {
    Name        = var.alarm_name
    Environment = var.environment
  }
}

# IAM Policy for CloudWatch Logs
resource "aws_iam_policy" "cloudwatch_logs_policy" {
  name        = "CloudWatchLogsPolicy"
  description = "Policy to allow ElastiCache to write logs to CloudWatch"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams",
          "logs:DescribeLogGroups"
        ]
        Resource = "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:${aws_cloudwatch_log_group.cache_logs.name}:*"
      }
    ]
  })
}

# Attach the Policy to an IAM Role
resource "aws_iam_role" "elasticache_role" {
  name               = "ElastiCacheRole"
  assume_role_policy = data.aws_iam_policy_document.elasticache_assume_role_policy.json

  tags = {
    Name        = "ElastiCacheRole"
    Environment = var.environment
  }
}

data "aws_iam_policy_document" "elasticache_assume_role_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["elasticache.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy_attachment" "cloudwatch_logs_policy_attachment" {
  role       = aws_iam_role.elasticache_role.name
  policy_arn = aws_iam_policy.cloudwatch_logs_policy.arn
}

