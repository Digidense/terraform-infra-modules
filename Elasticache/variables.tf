variable "cache_provider" {
  description = "The provider for the cache (aws or on-prem)"
  type        = string
  #default     = "aws"
}

variable "cache_engine" {
  description = "The name of the cache engine to be used for the clusters. Valid values: redis or memcached"
  type        = string
  # default     = "redis"
}

variable "elasticache" {
  description = "Tags for elasticache-replication-group"
  type = string
  default = "elasticache-replication-group"
}

variable "elasticache-cluster" {
  description = "Tags for elasticache-cluster"
  type = string
  default = "elasticache-cluster"
}

variable "instance_type" {
  description = "The instance type of the ElastiCache nodes"
  type        = string
  #default     = "cache.t2.micro"
}

variable "num_cache_nodes" {
  description = "The number of cache nodes"
  type        = number
  default     = 1
}

variable "multi_az" {
  description = "Specify if the cache cluster should be multi-AZ"
  type        = bool
  default     = false
}

variable "az_mode" {
  description = "The availability zone mode"
  type        = string
  default     = "single-az"
}

variable "aws_region" {
  description = "The AWS region to deploy the cluster"
  type        = string
  #default     = "us-west-2"
}

variable "cluster_id" {
  description = "The cluster ID for the ElastiCache cluster"
  type        = string
  #default     = "redis-cluster"
}
