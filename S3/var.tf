variable "bucket-name" {
  description = "The base name of the S3 bucket"
  type        = string

}

variable "string_length" {
  description = "The length of the random string"
  type        = number
  default     = 4
}

variable "string_special" {
  description = "Whether the random string should contain special characters"
  type        = bool
  default     = false
}

variable "string_upper" {
  description = "Whether the random string should be in uppercase"
  type        = bool
  default     = false
}

variable "lifecycle_expiration_days" {
  description = "The number of days after which objects with the lifecycle prefix will expire"
  type        = number
  default     = 90
}

variable "kms_key_description" {
  description = "The description of the KMS key"
  type        = string
  default     = "KMS key for S3 encryption"
}

variable "kms_key_deletion_window_days" {
  description = "The deletion window in days for the KMS key"
  type        = number
  default     = 7
}
