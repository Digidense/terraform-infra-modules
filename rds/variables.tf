#VPC and Region Configuration
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "count_num" {
  description = "number of subnets"
  type        = number
  default     = 2
}

variable "aws_db_subnet_group" {
  description = "Name of the database subnet group"
  type        = string
  default     = "subnet_group_db"
}

# KMS key configuration
variable "random_string_length" {
  description = "Length of the random string for KMS alias"
  type        = number
  default     = 4
}

variable "kms_alias_name_prefix" {
  description = "Prefix for the KMS alias name"
  type        = string
  default     = "dbs_key"
}

variable "deletion_window_in_days" {
  description = "Number of days before the KMS key is deleted"
  type        = number
  default     = 10
}

# Database Instance Configuration
variable "db_name" {
  description = "Name of the database"
  type        = string
}

variable "engine_version" {
  description = "Name of the engine"
  type        = string
}

variable "instance_class" {
  description =  "The instance class type for the RDS database instance"
  type        = string
}

variable "selected_engine" {
  description = "The selected RDS engine (mysql, postgres, mssql)"
  type        = string
}

# Database Storage Configuration
variable "allocated_storage" {
  description = "Allocated storage for the RDS instances"
  type        = number
  default     = 20
}

variable "storage_type" {
  description = "Storage type for the database"
  type        = string
  default     = "gp2"
}

# Database Username Configuration
variable "db_username" {
  description = "Username for the database"
  type        = string
  default     = "master_user"
}

# Database Password Length
variable "password_length" {
  description = "Length of the database password"
  type        = number
  default     = 15
}

# Database Password format
variable "password_format" {
  description = "Include special characters in the database password"
  type        = bool
  default     = true
}

# Database Accessibility
variable "publicly_accessible" {
  description = "Whether the database is publicly accessible"
  type        = bool
  default     = false
}

# Multi-AZ Deployment
variable "multi_az" {
  description = "Deploy the database across multiple availability zones"
  type        = bool
  default     = true
}

# Automatic Minor Version Upgrades
variable "auto_minor_version_upgrade" {
  description = "Whether minor version upgrades are applied automatically"
  type        = bool
  default     = true
}

# Tags for database instance
variable "environment" {
  description = "Environment tag"
  type        = string
  default     = "deployment"
}

# Secrets Manager Secret Name
variable "secret_name" {
  description = "Name for the Secrets Manager secret"
  type        = string
  default     = "secrets"
}

# special characters for secret name
variable "random_string_special" {
  description = "Whether the random string should include special characters"
  type        = bool
  default     = false
}

# Secrets Manager Recovery Window
variable "recovery_window_in_days" {
  description = "Recovery window in days for Secrets Manager"
  type        = number
  default     = 7
}

# Backup Retention Period
variable "retention_period" {
  description = "Retention period for automated backups"
  type        = number
}




