# Reference the VPC ID from the vpc_module
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc_module.vpc_id
}

output "public_subnet" {
  description = "The IDs of the public subnets"
  value       = module.vpc_module.public_subnet
}

output "private_subnet" {
  description = "The IDs of the private subnets"
  value       = module.vpc_module.private_subnet
}

output "security_group" {
  description = "The IDs of the security group"
  value = module.vpc_module.security_group
}

# Define the policy for the RDS KMS key
data "aws_iam_policy_document" "kms_policy" {
  statement {
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = ["arn:aws:kms:${var.region}:${data.aws_caller_identity.current.account_id}:key/${aws_kms_key.rds_kms_key.key_id}"]

    principals {
      type        = "Service"
      identifiers = ["rds.amazonaws.com"]
    }

    effect = "Allow"
  }

  statement {
    actions = [
      "kms:Create*",
      "kms:Describe*",
      "kms:Enable*",
      "kms:List*",
      "kms:Put*",
      "kms:Update*",
      "kms:Revoke*",
      "kms:Disable*",
      "kms:Get*",
      "kms:Delete*",
      "kms:ScheduleKeyDeletion",
      "kms:CancelKeyDeletion"
    ]
    resources = ["arn:aws:kms:${var.region}:${data.aws_caller_identity.current.account_id}:key/${aws_kms_key.rds_kms_key.key_id}"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    effect = "Allow"
  }

  statement {
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = ["arn:aws:kms:${var.region}:${data.aws_caller_identity.current.account_id}:key/${aws_kms_key.rds_kms_key.key_id}"]

    principals {
      type        = "Service"
      identifiers = ["logs.amazonaws.com"]
    }

    effect = "Allow"
  }
}

# Create KMS Key for RDS Encryption without policy
resource "aws_kms_key" "rds_kms_key" {
  description             = "KMS key for RDS encryption"
  deletion_window_in_days = var.deletion_window_in_days
  enable_key_rotation     = true

  tags = {
    Name        = "RDSKMSKey"
    Environment = var.environment
  }
}

# Attach the KMS policy to the RDS KMS key
resource "aws_kms_key_policy" "rds_key_policy" {
  key_id = aws_kms_key.rds_kms_key.id
  policy = data.aws_iam_policy_document.kms_policy.json
}

# Creates an AWS KMS alias name for the RDS KMS key
resource "aws_kms_alias" "rds_alias" {
  name          = var.rds_aliases_name
  target_key_id = aws_kms_key.rds_kms_key.arn
}



output "mysql_database_arn" {
  value = length(aws_db_instance.mysql_instance) > 0 ? aws_db_instance.mysql_instance[0].arn : null
}

output "postgres_database_arn" {
  value = length(aws_db_instance.postgres_instance) > 0 ? aws_db_instance.postgres_instance[0].arn : null
}

output "mssql_database_arn" {
  value = length(aws_db_instance.mssql_instance) > 0 ? aws_db_instance.mssql_instance[0].arn : null
}
