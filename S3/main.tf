# Create Random String for S3 Bucket Name
resource "random_string" "random_prefix" {
  length  = var.string_length
  special = var.string_special
  upper   = var.string_upper
}

# Create S3 Bucket with Server-Side Encryption and Lifecycle Rules
resource "aws_s3_bucket" "create_s3_bucket" {
  bucket = "${var.bucket_name}-${random_string.random_prefix.result}"
  acl    = var.bucket_acl

  versioning {
    enabled = var.versioning_enabled
  }

  lifecycle_rule {
    id      = var.lifecycle_rule_id
    enabled = var.lifecycle_rule_enabled

    transition {
      days          = var.transition_days_1
      storage_class = var.storage_class_1
    }

    dynamic "transition" {
      for_each = var.use_glacier ? [1] : []
      content {
        days          = var.transition_days_2
        storage_class = var.storage_class_2
      }
    }
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.elasticache_kms_key.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  tags = {
    Environment = "S3"
  }
}

# Enable S3 Bucket Metrics
resource "aws_s3_bucket_metric" "enable_metrics_bucket" {
  bucket = aws_s3_bucket.create_s3_bucket.bucket
  name   = "EntireBucket"
}

# Create IAM Role for S3 Access
resource "aws_iam_role" "s3_read_role" {
  name = "s3_read_role"

  assume_role_policy = data.aws_iam_policy_document.s3_assume_role_policy.json

  inline_policy {
    name   = "s3_read_policy"
    policy = data.aws_iam_policy_document.s3_read_policy.json
  }
}

resource "aws_iam_role" "s3_read_write_role" {
  name = "s3_read_write_role"

  assume_role_policy = data.aws_iam_policy_document.s3_assume_role_policy.json

  inline_policy {
    name   = "s3_read_write_policy"
    policy = data.aws_iam_policy_document.s3_read_write_policy.json
  }
}

resource "aws_iam_role_policy" "s3_read_kms_policy" {
  role = aws_iam_role.s3_read_role.id
  policy = data.aws_iam_policy_document.s3_kms_policy.json
}

resource "aws_iam_role_policy" "s3_read_write_kms_policy" {
  role = aws_iam_role.s3_read_write_role.id
  policy = data.aws_iam_policy_document.s3_kms_policy.json
}

# Data Sources for IAM Policies
data "aws_iam_policy_document" "s3_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "s3_read_policy" {
  statement {
    actions   = ["s3:GetObject", "s3:ListBucket"]
    resources = [
      "${aws_s3_bucket.create_s3_bucket.arn}",
      "${aws_s3_bucket.create_s3_bucket.arn}/*"
    ]
  }
}

data "aws_iam_policy_document" "s3_read_write_policy" {
  statement {
    actions   = ["s3:GetObject", "s3:ListBucket", "s3:PutObject"]
    resources = [
      "${aws_s3_bucket.create_s3_bucket.arn}",
      "${aws_s3_bucket.create_s3_bucket.arn}/*"
    ]
  }
}

data "aws_iam_policy_document" "s3_kms_policy" {
  statement {
    actions = [
      "kms:Decrypt",
      "kms:Encrypt",
      "kms:GenerateDataKey",
      "kms:GenerateDataKeyWithoutPlaintext",
      "kms:ReEncryptFrom",
      "kms:ReEncryptTo"
    ]
    resources = [aws_kms_key.elasticache_kms_key.arn]
  }
}

# Create KMS Key for Encryption
resource "aws_kms_key" "elasticache_kms_key" {
  description             = "KMS key for ElastiCache encryption"
  deletion_window_in_days = var.deletion_window_in_days
  enable_key_rotation     = true
}

# Creates an AWS KMS alias name
resource "aws_kms_alias" "my_alias" {
  name          = var.aliases_name
  target_key_id = aws_kms_key.elasticache_kms_key.arn
}
