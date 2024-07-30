module "kms_module" {
  source                  = "git::https://github.com/Digidense/terraform_module.git//kms?ref=feature/DD-35/kms_module"
  aliases_name            = "alias/Kms_S3_Module"
  description             = "KMS module attachment"
  deletion_window_in_days = var.kms_key_deletion_window_days
  enable_key_rotation     = true
}

resource "random_string" "random_prefix" {
  length  = var.string_length
  special = var.string_special
  upper   = var.string_upper
}

resource "aws_s3_bucket" "create_s3_bucket" {
  bucket = "${var.bucket-name}-${random_string.random_prefix.result}"
  acl    = "private"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    id      = "archive"
    enabled = true

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 60
      storage_class = "GLACIER"
    }
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = module.kms_module.kms_key_arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  tags = {
    Environment = "S3"
  }
}

resource "aws_s3_bucket_metric" "enable_metrics_bucket" {
  bucket = aws_s3_bucket.create_s3_bucket.bucket
  name   = "EntireBucket"
}

locals {
  s3_actions = {
    read = [
      "s3:GetObject",
      "s3:ListBucket"
    ]
    read_write = [
      "s3:GetObject",
      "s3:ListBucket",
      "s3:PutObject"
    ]
  }
}

resource "aws_iam_role" "s3_role" {
  for_each = local.s3_actions

  name = "s3_${each.key}_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  inline_policy {
    name = "s3_${each.key}_policy"
    policy = jsonencode({
      Version = "2012-10-17",
      Statement = [
        {
          Effect = "Allow",
          Action = each.value,
          Resource = [
            "${aws_s3_bucket.create_s3_bucket.arn}",
            "${aws_s3_bucket.create_s3_bucket.arn}/*"
          ]
        }
      ]
    })
  }
}
