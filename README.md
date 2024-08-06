# AWS S3 Bucket with Server-Side Encryption and IAM Roles

This Terraform configuration creates an Amazon S3 bucket with server-side encryption using AWS KMS, lifecycle rules, and associated IAM roles and policies for access control. It also enables metrics for the S3 bucket.

## Resources Created

### Random String for S3 Bucket Name
- **random_string.random_prefix**: Generates a random string to be used as a prefix for the S3 bucket name.

### S3 Bucket
- **aws_s3_bucket.create_s3_bucket**: Creates an S3 bucket with server-side encryption using AWS KMS, versioning, and lifecycle rules.

### S3 Bucket Lifecycle Rules
- **aws_s3_bucket.lifecycle_rule**: Defines lifecycle rules for the S3 bucket, including transitions to different storage classes.

### Server-Side Encryption
- **aws_s3_bucket.server_side_encryption_configuration**: Configures server-side encryption with AWS KMS.

### S3 Bucket Metrics
- **aws_s3_bucket_metric.enable_metrics_bucket**: Enables metrics for the entire S3 bucket.

### IAM Roles and Policies
- **aws_iam_role.s3_read_role**: IAM role for read access to the S3 bucket.
- **aws_iam_role.s3_read_write_role**: IAM role for read and write access to the S3 bucket.
- **aws_iam_role_policy.s3_read_kms_policy**: Policy for KMS permissions for the read role.
- **aws_iam_role_policy.s3_read_write_kms_policy**: Policy for KMS permissions for the read/write role.

### KMS Key for Encryption
- **aws_kms_key.elasticache_kms_key**: KMS key for server-side encryption of the S3 bucket.
- **aws_kms_alias.my_alias**: Alias for the KMS key.

## Variables

- **string_length**: Length of the random string for the bucket name prefix.
- **string_special**: Whether the random string should include special characters.
- **string_upper**: Whether the random string should include uppercase characters.
- **bucket_name**: Base name of the S3 bucket.
- **bucket_acl**: Access control list for the S3 bucket.
- **versioning_enabled**: Whether versioning is enabled for the S3 bucket.
- **lifecycle_rule_id**: ID for the lifecycle rule.
- **lifecycle_rule_enabled**: Whether the lifecycle rule is enabled.
- **transition_days_1**: Number of days before the first transition.
- **storage_class_1**: Storage class for the first transition.
- **transition_days_2**: Number of days before the second transition (if using Glacier).
- **storage_class_2**: Storage class for the second transition (if using Glacier).
- **use_glacier**: Whether to use Glacier for storage transitions.
- **deletion_window_in_days**: Deletion window for the KMS key.
- **aliases_name**: Alias name for the KMS key.

## Data Sources

- **data.aws_iam_policy_document.s3_assume_role_policy**: Policy document for assuming the S3 read and read/write roles.
- **data.aws_iam_policy_document.s3_read_policy**: Policy document for read access to the S3 bucket.
- **data.aws_iam_policy_document.s3_read_write_policy**: Policy document for read/write access to the S3 bucket.
- **data.aws_iam_policy_document.s3_kms_policy**: Policy document for KMS permissions.

## Usage

1. Define the required variables in a `terraform.tfvars` file or as environment variables.
2. Run `terraform init` to initialize the configuration.
3. Run `terraform apply` to create the resources.

## Notes

- Ensure that you have the necessary AWS credentials configured.
- Review the IAM policies to ensure they meet your security requirements.
- The lifecycle rules and transitions are configurable based on your specific needs.

