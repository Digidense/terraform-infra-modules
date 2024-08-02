# Define VPC module
module "vpc_module_rds" {
  source = "git::https://github.com/Digidense/terraform_module.git//vpc?ref=feature/DD-42-VPC_module"
}

# Create KMS Key for Encryption
resource "aws_kms_key" "rds_kms_key" {
  description             = "KMS key for ElastiCache encryption"
  deletion_window_in_days = var.deletion_window_in_days
  enable_key_rotation = true

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
  engine_version                      = "8.0.35"
  allocated_storage                   = var.allocated_storage
  storage_type                        = var.storage_type
  username                            = var.db_username
  password                            = random_password.user_passwords["db"].result
#  parameter_group_name                = aws_db_parameter_group.example.name
  publicly_accessible                 = var.publicly_accessible
  multi_az                            = var.multi_az
  backup_retention_period             = var.backup_retention_period
  auto_minor_version_upgrade          = var.auto_minor_version_upgrade
  db_subnet_group_name                = aws_db_subnet_group.example.name
  vpc_security_group_ids              = [module.vpc_module_rds.security_group_id]
  iam_database_authentication_enabled = true
  tags = {
    Name        = var.tag_name.name
    Environment = var.tag_name.environment
  }
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
  subnet_ids = [
    module.vpc_module_rds.subnet_pri01,
    module.vpc_module_rds.subnet_pri02
  ]
}

# Backups Replication
resource "aws_db_instance_automated_backups_replication" "example1" {
  source_db_instance_arn = aws_db_instance.example.arn
  retention_period       = 14
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

# Attach policy to three users
resource "aws_iam_user_policy_attachment" "user_policy_attachments" {
  for_each = local.iam_users_policies

  user       = each.value
  policy_arn = aws_iam_policy.rds_access_policy.arn
}

