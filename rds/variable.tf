variable "secret_name" {
  description = "Name for the AWS Secrets Manager secret"
  type        = string
#  default     = "Secret-Tria"
}

variable "secret-tags" {
  description = "Name for the AWS Secrets Manager secret"
  type        = string
#  default     = "Database Credentials"
}

variable "db_username" {
  description = "Username for the PostgreSQL database"
  type        = string
#  default     = "PostgreSQL"
}

variable "db_username_password" {
  description = "db_username_password  for the PostgreSQL database"
  type        = string
#  default     = "password"
}

variable "recovery_window_in_days" {
  description = "recovery_window_in_days for secret manager deletion"
  type        = number
  default     = 7
}

variable "db_name" {
  description = "recovery_window_in_days for secret manager deletion"
  type        = string
#  default     = "unique-database"
}

variable "instance_class" {
  description = "instance_class  of the db"
  type        = string
#  default     = "db.t3.micro"
}

variable "engine_name" {
  description = "engine_name of the db"
  type        = string
#  default     = "postgres"
}

variable "engine_version" {
  description = "engine_version of the db"
  type        = string
#  default     = "12.17"
}

variable "parameter_group_name" {
  description = "parameter_group_name of the db"
  type        = string
  default     = "default.postgres12"
}

variable "value_t" {
  description = "true value of db"
  type        = bool
  default     = true
}

variable "value_f" {
  description = "false value of db"
  type        = bool
  default     = false
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


variable "aws_db_subnet_group" {
  description = "aws_db_subnet_group of the db"
  type        = string
  default     = "subnet_group_db"
}

variable "application_user" {
  description = "application_user of the db"
  type        = string
  default     = "application_user"
}

variable "policy" {
  description = "policy of the db"
  type        = string
  default     = "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
}

variable "backup_window" {
  description = "backup_window of the db"
  type        = string
  default     = "03:00-04:00"
}

variable "storage_type" {
  description = "storage of the db"
  type        = string
  default     = "gp2"
}

