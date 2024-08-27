# Define VPC module
module "vpc_module" {
  source    = "git::https://github.com/Digidense/terraform-infra-modules.git//vpc?ref=feature/vpc_module"
  vpc_cidr  = var.vpc_cidr
  region    = var.region
  count_num = var.count_num
}

# Retrieves information about the current AWS account
data "aws_caller_identity" "current" {}

# Define the policy for the RDS KMS key
data "aws_iam_policy_document" "kms_policy_rds" {
  statement {
    actions = [
      "kms:*"
    ]
    resources = ["*"]
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
    resources = ["arn:aws:kms:${var.region}:${data.aws_caller_identity.current.account_id}:key/${aws_kms_key.rds_kms_key_main.key_id}"]

    principals {
      type        = "Service"
      identifiers = ["rds.amazonaws.com"]
    }

    effect = "Allow"
  }
}

# Create KMS Key for RDS Encryption without policy
resource "aws_kms_key" "rds_kms_key_main" {
  description             = "KMS key for RDS encryption"
  deletion_window_in_days = var.deletion_window_in_days
  enable_key_rotation     = true

  tags = {
    Name        = "RDSKMSKey"
    Environment = var.environment
  }
}

# Attach the KMS policy to the RDS KMS key
resource "aws_kms_key_policy" "rds_key_policy_main" {
  key_id = aws_kms_key.rds_kms_key_main.id
  policy = data.aws_iam_policy_document.kms_policy_rds.json
}

# Creates an AWS KMS alias name for the RDS KMS key
resource "random_string" "unique_id" {
  length  = var.random_string_length
  special = false
}

# Creates an AWS KMS alias name for the RDS KMS key
resource "aws_kms_alias" "rds_alias_main" {
  name          = "alias/${var.kms_alias_name_prefix}_${random_string.unique_id.result}"
  target_key_id = aws_kms_key.rds_kms_key_main.arn
}


# Define subnet group for the RDS instances
resource "aws_db_subnet_group" "subnet_gp" {
  name       = var.aws_db_subnet_group
  subnet_ids = module.vpc_module.private_subnet
  tags = {
    Name        = var.aws_db_subnet_group
    Environment = var.environment
  }
}

# Local Variables for Engine Type Selection
locals {
  create_mysql    = var.selected_engine == "mysql"
  create_postgres = var.selected_engine == "postgres"
  create_mssql    = var.selected_engine == "mssql"

  total_selected = length(compact([local.create_mysql, local.create_postgres, local.create_mssql]))
}

# MySQL Database Instance
resource "aws_db_instance" "mysql_instance" {
  count                               = local.create_mysql ? 1 : 0
  identifier                          = "${var.db_name}-${var.selected_engine}"
  instance_class                      = var.instance_class
  engine                              = var.selected_engine
  engine_version                      = var.engine_version
  allocated_storage                   = var.allocated_storage
  storage_type                        = var.storage_type
  username                            = var.db_username
  password                            = random_password.db_password.result
  publicly_accessible                 = var.publicly_accessible
  multi_az                            = var.multi_az
  backup_retention_period             = var.retention_period
  auto_minor_version_upgrade          = var.auto_minor_version_upgrade
  storage_encrypted                   = true
  skip_final_snapshot                 = false
  final_snapshot_identifier           = "final-snapshot-${var.db_name}-${var.selected_engine}"
  db_subnet_group_name                = aws_db_subnet_group.subnet_gp.name
  vpc_security_group_ids              = [module.vpc_module.security_group.id]
  kms_key_id                          = aws_kms_key.rds_kms_key_main.arn
  iam_database_authentication_enabled = true
  tags = {
    Name        = "${var.db_name}-${var.selected_engine}"
    Environment = var.environment
  }
}

# PostgreSQL Database Instance
resource "aws_db_instance" "postgres_instance" {
  count                               = local.create_postgres ? 1 : 0
  identifier                          = "${var.db_name}-${var.selected_engine}"
  instance_class                      = var.instance_class
  engine                              = var.selected_engine
  engine_version                      = var.engine_version
  allocated_storage                   = var.allocated_storage
  storage_type                        = var.storage_type
  username                            = var.db_username
  password                            = random_password.db_password.result
  publicly_accessible                 = var.publicly_accessible
  multi_az                            = var.multi_az
  backup_retention_period             = var.retention_period
  auto_minor_version_upgrade          = var.auto_minor_version_upgrade
  storage_encrypted                   = true
  skip_final_snapshot                 = false
  final_snapshot_identifier           = "final-snapshot-${var.db_name}-${var.selected_engine}"
  db_subnet_group_name                = aws_db_subnet_group.subnet_gp.name
  vpc_security_group_ids              = [module.vpc_module.security_group.id]
  kms_key_id                          = aws_kms_key.rds_kms_key_main.arn
  iam_database_authentication_enabled = true
  tags = {
    Name        = "${var.db_name}-${var.selected_engine}"
    Environment = var.environment
  }
}

# Microsoft SQL Server Database Instance
resource "aws_db_instance" "mssql_instance" {
  count                               = local.create_mssql ? 1 : 0
  identifier                          = "${var.db_name}-${var.selected_engine}"
  instance_class                      = var.instance_class
  engine                              = var.selected_engine
  engine_version                      = var.engine_version
  allocated_storage                   = var.allocated_storage
  storage_type                        = var.storage_type
  username                            = var.db_username
  password                            = random_password.db_password.result
  publicly_accessible                 = var.publicly_accessible
  multi_az                            = var.multi_az
  backup_retention_period             = var.retention_period
  auto_minor_version_upgrade          = var.auto_minor_version_upgrade
  storage_encrypted                   = true
  skip_final_snapshot                 = false
  final_snapshot_identifier           = "final-snapshot-${var.db_name}-${var.selected_engine}"
  db_subnet_group_name                = aws_db_subnet_group.subnet_gp.name
  vpc_security_group_ids              = [module.vpc_module.security_group.id]
  kms_key_id                          = aws_kms_key.rds_kms_key_main.arn
  iam_database_authentication_enabled = true
  tags = {
    Name        = "${var.db_name}-${var.selected_engine}"
    Environment = var.environment
  }
}

# Generate a random password for the database user
resource "random_password" "db_password" {
  length           = var.password_length
  special          = var.password_format
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# Generate Random String for Secrets
resource "random_string" "random_secrets" {
  length  = var.random_string_length
  special = var.random_string_special
}

# Create Secrets Manager Secret for Database Credentials
resource "aws_secretsmanager_secret" "db_credentials" {
  name        = "${var.db_name}-${var.secret_name}-${random_string.random_secrets.result}"
  description = "Database credentials for ${var.db_name}"
}

resource "aws_secretsmanager_secret_version" "db_credentials_version" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = var.db_username
    password = random_password.db_password.result
  })
}

# IAM Policy for RDS Access
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
        Resource = concat(
          length(aws_db_instance.mysql_instance) > 0 ? [
            "arn:aws:rds-db:${var.region}:${data.aws_caller_identity.current.account_id}:dbuser:${aws_db_instance.mysql_instance[0].id}/${var.db_username}"
          ] : [],
          length(aws_db_instance.postgres_instance) > 0 ? [
            "arn:aws:rds-db:${var.region}:${data.aws_caller_identity.current.account_id}:dbuser:${aws_db_instance.postgres_instance[0].id}/${var.db_username}"
          ] : [],
          length(aws_db_instance.mssql_instance) > 0 ? [
            "arn:aws:rds-db:${var.region}:${data.aws_caller_identity.current.account_id}:dbuser:${aws_db_instance.mssql_instance[0].id}/${var.db_username}"
          ] : []
        )
      }
    ]
  })
}

# Local variable defining IAM users to be created
locals {
  iam_users_policies = {
    application_user = aws_iam_user.users["application_user"].name
    readonly_user    = aws_iam_user.users["readonly_user"].name
    flyway_user      = aws_iam_user.users["flyway_user"].name
  }

  users = {
    "application_user" = "Application_user"
    "readonly_user"    = "ReadOnly_user"
    "flyway_user"      = "Flyway_user"
  }
}

# Resource to create IAM users as defined in the local.users map
resource "aws_iam_user" "users" {
  for_each = local.users
  name     = each.value
}

# Resource to attach the RDS access policy to each IAM user
resource "aws_iam_user_policy_attachment" "user_policy_attachments" {
  for_each   = local.iam_users_policies
  user       = each.value
  policy_arn = aws_iam_policy.rds_access_policy.arn
}

