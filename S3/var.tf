# Variables for KMS
variable "aliases_name" {
  description = "Aliases_name for KMS"
  type        = string
  default     = "alias/kms_2058"
}

variable "deletion_window_in_days" {
  description = "Deletion window in days for KMS"
  type        = number
  default     = 7
}

# Variables for S3
variable "bucket_name" {
  description = "The base name of the S3 bucket"
  type        = string
}


variable "bucket_acl" {
  description = "The ACL of the S3 bucket"
  type        = string
  default     = "private"
}

variable "versioning_enabled" {
  description = "Enable versioning on the S3 bucket"
  type        = bool
  default     = true
}

variable "lifecycle_rule_id" {
  description = "The ID of the lifecycle rule"
  type        = string
  default     = "archive"
}

variable "lifecycle_rule_enabled" {
  description = "Enable the lifecycle rule"
  type        = bool
  default     = true
}

variable "transition_days_1" {
  description = "Days after which to transition to the first storage class"
  type        = number
  default     = 30
}

variable "storage_class_1" {
  description = "The first storage class to transition to"
  type        = string
  default     = "STANDARD_IA"
}

variable "transition_days_2" {
  description = "Days after which to transition to the second storage class"
  type        = number
  default     = 60
}

variable "storage_class_2" {
  description = "The second storage class to transition to"
  type        = string
  default     = "GLACIER"
}

variable "use_glacier" {
  description = "Whether to use GLACIER storage class for transition"
  type        = bool
}
