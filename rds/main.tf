# Import VPC Module
module "vpc_module" {
  source    = "git::https://github.com/Digidense/terraform-infra-modules.git//vpc?ref=feature/vpc_module"
  vpc_cidr  = var.vpc_cidr
  region    = var.region
  count_num = var.count_num
}

resource "aws_kms_key" "rds_kms_key" {
  description             = "KMS key for RDS encryption"
  deletion_window_in_days = var.deletion_window_in_days
  enable_key_rotation     = true

  tags = {
    Name        = "RDSKMSKey"
    Environment = "deployment"
  }
}

# Define the policy for the KMS key
data "aws_iam_policy_document" "kms_policy" {
  statement {
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = [aws_kms_key.rds_kms_key.arn]

    principals {
      type        = "Service"
      identifiers = ["rds.amazonaws.com"]
    }

    effect = "Allow"
  }
}

# Attach the policy to the KMS key using aws_kms_key_policy
resource "aws_kms_key_policy" "rds_kms_policy" {
  key_id = aws_kms_key.rds_kms_key.key_id
  policy = data.aws_iam_policy_document.kms_policy.json
}

# Creates an AWS KMS alias name
resource "aws_kms_alias" "my_alias" {
  name          = var.aliases_name
  target_key_id = aws_kms_key.rds_kms_key.arn
}



# Creating the RDS database with the generated password
resource "aws_db_instance" "example" {
  identifier                          = var.db_name
  instance_class                      = var.instance_type
  engine                              = var.engine_name
  engine_version                      = var.engine_name
  allocated_storage                   = var.allocated_storage
  storage_type                        = var.storage_type
  username                            = var.db_username
  password                            = random_password.user_passwords["db"].result
  multi_az                            = var.multi_az
  auto_minor_version_upgrade          = var.auto_minor_version_upgrade
  db_subnet_group_name                = aws_db_subnet_group.example.name
  vpc_security_group_ids              = [module.vpc_module.sg]
  iam_database_authentication_enabled = true
  tags = {
    Name        = var.tag_name.name
    Environment = var.tag_name.environment
  }
}

# Custom policy for RDS access
resource "aws_iam_policy" "rds_access_policy" {
  name        = "RDSAccessPolicy"
  description = "Policy to allow RDS access for IAM users"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "rds-db:connect"
        ],
        Resource = "*"
      }
    ]
  })
}
# Define local values for users and policies
locals {
  iam_users_policies = {
    application_user = aws_iam_user.users["application_user"].name
    readonly_user    = aws_iam_user.users["readonly_user"].name
    flyway_user      = aws_iam_user.users["flyway_user"].name
  }

  users = {
    "application_user" = "Application"
    "readonly_user"    = "ReadOnly"
    "flyway_user"      = "Flyway"
  }
}

# Generate random passwords for each users
resource "random_password" "user_passwords" {
  for_each = local.users

  length           = var.password_length
  special          = var.password_format
  override_special = "!#$%&*()@"
}

# Secret Manager creation
resource "aws_secretsmanager_secret" "db_credentials" {
  name                    = var.secret_name
  recovery_window_in_days = var.recovery_window_in_days
}

# Secret Manager version creation with the auto-generated database password
resource "aws_secretsmanager_secret_version" "db_credentials_version" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = var.db_username
    password = random_password.user_passwords["db"].result
  })
}

# Creating the RDS subnet group
resource "aws_db_subnet_group" "example" {
  name = var.aws_db_subnet_group
  subnet_ids = module.vpc_module.private_subnet
  tags = {
    Name        = var.aws_db_subnet_group
    Environment = "deployment"
  }

}

# Backups Replication
resource "aws_db_instance_automated_backups_replication" "example1" {
  source_db_instance_arn = aws_db_instance.example.arn
  retention_period       = var.retention_period
}

# Create Three users
resource "aws_iam_user" "users" {
  for_each = {
    application_user = var.application_user
    readonly_user    = var.readonly_user
    flyway_user      = var.flyway_user
  }

  name = each.value
}


# Attach policy to three users
resource "aws_iam_user_policy_attachment" "user_policy_attachments" {
  for_each = local.iam_users_policies

  user       = each.value
  policy_arn = aws_iam_policy.rds_access_policy.arn
}
