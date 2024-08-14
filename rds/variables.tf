variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "192.168.0.0/24"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "count_num" {
  description = "number of subnets"
  type        = number
  default     = 2
}

variable "deletion_window_in_days" {
  description = "Number of days before the KMS key is deleted"
  type        = number
  default     = 10
}

variable "rds_aliases_name" {
  description = "The alias name for the RDS KMS key"
  type        = string
  default     = "alias/db_xxx_key"
}

variable "random_string_length" {
  description = "Length of the random string for KMS alias"
  type        = number
  default     = 6
}

variable "kms_alias_name_prefix" {
  description = "Prefix for the KMS alias name"
  type        = string
  default     = "db_xxx_key"
}

variable "db_name" {
  description = "Name of the database"
  type        = string
}

variable "engine_names" {
  description = "List of database engine names"
  type        = list(string)
  default     = ["mysql", "postgres", "sqlserver"]
}


variable "instance_type" {
  description = "Instance type for the RDS instances"
  type        = string
}

variable "engine_version" {
  description = "Engine version"
  type        = string
}

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

variable "db_username" {
  description = "Username for the database"
  type        = string
    default = "master_user"
}

variable "publicly_accessible" {
  description = "Whether the database is publicly accessible"
  type        = bool
  default     = false
}

variable "multi_az" {
  description = "Whether the database should be deployed across multiple availability zones"
  type        = bool
  default     = true
}


variable "auto_minor_version_upgrade" {
  description = "Whether minor version upgrades are applied automatically"
  type        = bool
  default     = true
}

variable "aws_db_subnet_group" {
  description = "Name of the database subnet group"
  type        = string
  default     = "subnet_group_db"
}

variable "environment" {
  description = "Environment tag"
  type        = string
  default     = "deployment"
}

variable "password_length" {
  description = "Length of the database password"
  type        = number
  default     = 15
}


variable "password_format" {
  description = "Whether the database password should include special characters"
  type        = bool
  default     = true
}

variable "mysql_instance" {
  description = "Set to 'true' to create a MySQL instance, 'false' to skip its creation"
  type        = bool
}

variable "postgres_instance" {
  description = "Set to 'true' to create a PostgreSQL instance, 'false' to skip its creation"
  type        = bool
}

variable "mssql_instance" {
  description = "Set to 'true' to create an MS SQL instance, 'false' to skip its creation"
  type        = bool
}

variable "secret_name" {
  description = "Name for the Secrets Manager secret"
  type        = string
  default     = "databse_new_secret"
}

variable "recovery_window_in_days" {
  description = "Recovery window in days for Secrets Manager"
  type        = number
  default     = 7
}

variable "retention_period" {
  description = "Retention period for automated backups"
  type        = number
}




