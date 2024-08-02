# Reference the KMS Ids
output "kms_key_id" {
  description = "The ID of the KMS key"
  value       = aws_kms_key.elasticache_kms_key.id
}

output "kms_key_arn" {
  description = "The ARN of the KMS key"
  value       = aws_kms_key.elasticache_kms_key.arn
}
