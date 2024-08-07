# Variables for Elasticache
variable "cache_provider" {
  description = "The provider for the cache "
  type        = string
  default     = "aws"
}

variable "cache_engine" {
  description = "The name of the cache engine to be used for the clusters. Valid values: redis or memcached"
  type        = string
  default     = "memcached"
}

variable "ElastiCacheKMSKey" {
  description = "The name of the ElastiCacheKMSKey"
  type        = string
  default     = "ElastiCacheKMSKey"
}

variable "engine_version" {
  description = "Engine_version for redis or memcached"
  type        = string
  default     = "1.6.22"
}

variable "num_node_groups" {
  description = "Number of node groups for your cluster"
  type        = number
  default     = 1
}

variable "elasticache" {
  description = "Tags for elasticache-replication-group"
  type        = string
  default     = "elasticache-replication-group"
}

variable "elasticache_cluster" {
  description = "Tags for elasticache-cluster"
  type        = string
  default     = "elasticache-cluster"
}

variable "instance_type" {
  description = "The instance type of the ElastiCache nodes"
  type        = string
  default     = "cache.t2.micro"
}

variable "num_cache_nodes" {
  description = "The number of cache nodes"
  type        = number
  default     = 2
}

variable "multi_az" {
  description = "Specify if the cache cluster should be multi-AZ"
  type        = bool
  default     = true
}

variable "port_no" {
  description = "Port number for elasticache"
  type        = number
  default     = 11211
}

variable "az_mode" {
  description = "The availability zone mode"
  type        = string
  default     = "single-az"
}

variable "aws_region" {
  description = "The AWS region to deploy the cluster"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "The cluster name for the ElastiCache cluster"
  type        = string
  default     = "memcached"

}

# Variables for KMS
variable "aliases_name" {
  description = "Aliases_name for KMS "
  type        = string
  default     = "alias/kms_keys"
}

variable "deletion_window_in_days" {
  description = "deletion_window_in_days for KMS "
  type        = number
  default     = 7
}

# Variables for VPC
variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "region" {
  description = "The AWS region to create resources in"
  type        = string
}

variable "count_num" {
  description = "Number of subnets"
  type        = number
}

# Variables for Alarm
variable "alarm_threshold" {
  description = "The threshold for triggering the CloudWatch alarm"
  type        = number
  default     = 80
}

variable "alarm_period" {
  description = "The period over which the specified statistic is applied"
  type        = number
  default     = 300
}

variable "evaluation_periods" {
  description = "The number of periods over which data is compared to the specified threshold"
  type        = number
  default     = 2
}

variable "alarm_actions" {
  description = "The list of actions to execute when this alarm transitions into an ALARM state"
  type        = list(string)
  default     = []
}

variable "elasticache_subnet_group" {
  description = "Subnet group for ElastiCache"
  type        = string
  default     = "elasticache-subnet-group"
}

variable "cloudwatch_logs" {
  description = "cloudwatch-logs for ElastiCache"
  type        = string
  default     = "cloudwatch-logs"
}

variable "logs_formates" {
  description = "logs-formates for ElastiCache"
  type        = string
  default     = "text"
}

variable "log_type" {
  description = "log_type for ElastiCache"
  type        = string
  default     = "engine-log"
}

variable "cache_logs_name" {
  description = "cache_logs for ElastiCache"
  type        = string
  default     = "redis-slow-logs"
}

variable "elasticache_pg_memcached" {
  description = "elasticache-pg for memcached ElastiCache"
  type        = string
  default     = "elasticache-pg"
}

variable "pg_family_memcached" {
  description = "pg_family for memcached ElastiCache"
  type        = string
  default     = "memcached1.6"
}

variable "elasticache_pg_redis" {
  description = "elasticache-pg for redis ElastiCache"
  type        = string
  default     = "cache-params"
}

variable "pg_family_redis" {
  description = "pg_family for redis ElastiCache"
  type        = string
  default     = "redis6.x"
}

variable "parameter_name" {
  description = "parameter_group parameter name"
  type        = string
  default     = "activerehashing"
}

variable "alarm_name" {
  description = "Name of the elasticache_cpu_alarm"
  type        = string
  default     = "ElasticacheCPUUtilizationHigh"
}

variable "environment" {
  description = "this block is for environment"
  type        = string
  default     = "Development"
}