variable "db_name" {
  description = "Name of the database"
  type        = string
}

variable "instance_type" {
  description = "Instance class of the database"
  type        = string
}

variable "engine_name" {
  description = "Engine name of the database"
  type        = string
}

variable "engine_version" {
  description = "Engine version of the database"
  type        = string
}

variable "allocated_storage" {
  description = "Allocated storage for the database"
  type        = number
  default     = 20
}

variable "storage_type" {
  description = "Storage type for the database"
  type        = string
  default     = "gp2"
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

variable "retention_period" {
  description = "The retention period for automated backups replication"
  type        = number
  default     = 14
}

variable "backup_retention_period" {
  description = "Backup retention period in days for the database"
  type        = number
  default     = 7
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

variable "secret_name" {
  description = "Name for the AWS Secrets Manager secret"
  type        = string
  default     = "db_secrets"
}

variable "db_username" {
  description = "Username for the database"
  type        = string
}

variable "tag_name" {
  description = "tag_name of the db"
  type = list(object({
    name        = string
    environment = string
  }))
  default = [
    {
      name        = "my-postgres-db"
      environment = "production"
    }
  ]
}

variable "recovery_window_in_days" {
  description = "Recovery window in days for Secrets Manager deletion"
  type        = number
  default     = 7
}

variable "application_user" {
  description = "Name of the application user"
  type        = string
  default     = "application_user"
}

variable "readonly_user" {
  description = "Name of the readonly user"
  type        = string
  default     = "readonly_user"
}

variable "flyway_user" {
  description = "Name of the flyway user"
  type        = string
  default     = "flyway_user"
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
