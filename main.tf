resource "aws_s3_bucket" "create_s3_bucket" {
  bucket = var.bucket-name
  acl    = "private"


  module "Kms_module" {
    source                  = "git::https://github.com/Digidense/terraform_module.git//kms?ref=feature/DD-35/kms_module"
    aliases_name            = "alias/Kms_S3_Module"
    description             = "kms module attachment"
    deletion_window_in_days = 7
    enable_key_rotation     = true
  }

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
        kms_master_key_id = module.Kms_module.kms_key_arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  tags = {
    Environment = "S3"
  }
}

resource "aws_s3_bucket_metric" "enable_metrics_bucket" {
  bucket = var.bucket-name
  name   = "EntireBucket"
}

resource "aws_iam_policy" "s3_bucket_policy" {
  name        = "s3_bucket_policy"
  description = "IAM policy for S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
        ],
        Resource = "${aws_s3_bucket.create_s3_bucket.arn}/*"
      },
    ]
  })
}


