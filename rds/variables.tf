variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default = "192.168.0.0/24"
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "count_num" {
  description = "number of subnets"
  type        = number
}

variable "deletion_window_in_days" {
  description = "Number of days before the KMS key is deleted"
  type        = number
  default = 30
}

variable "aliases_name" {
  description = "Alias name for the KMS key"
  type        = string
  default     = "rds_kms_key"
}

variable "db_name" {
  description = "Name of the database"
  type        = string
}

variable "engine_name" {
  description = "Engine name of the database"
  type        = string
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
  default = 20
}

variable "storage_type" {
  description = "Storage type for the database"
  type        = string
  default     = "gp2"
}

variable "db_username" {
  description = "Username for the database"
  type        = string
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
  default = "deployment"
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
  description = "Whether to create a MySQL instance"
  type        = bool
  default     = true
}

variable "postgres_instance" {
  description = "Whether to create a PostgreSQL instance"
  type        = bool
  default     = true
}

variable "mssql_instance" {
  description = "Whether to create an Oracle instance"
  type        = bool
  default     = true
}

variable "secret_name" {
  description = "Name for the Secrets Manager secret"
  type        = string
  default = "db_secret"
}

variable "recovery_window_in_days" {
  description = "Recovery window in days for Secrets Manager"
  type        = number
  default = 7
}

variable "retention_period" {
  description = "Retention period for automated backups"
  type        = number
}

variable "application_user" {
  description = "Name of the application user"
  type        = string
  default = "application_user"
}

variable "readonly_user" {
  description = "Name of the read-only user"
  type        = string
  default = "readonly_user"
}

variable "flyway_user" {
  description = "Name of the Flyway user"
  type        = string
  default = "flyway_user"
}
