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
    Environment = var.environment
  }
}

resource "aws_db_subnet_group" "example1" {
  name       = var.aws_db_subnet_group
  subnet_ids = module.vpc_module.private_subnet
  tags = {
    Name        = var.aws_db_subnet_group
    Environment = var.environment
  }
}

# MySQL Database Instance
resource "aws_db_instance" "mysql_instance" {
  count                               = var.engine_name == "MySQL" ? 1 : 0
  identifier                          = var.db_name
  instance_class                      = var.instance_type
  engine                              = var.engine_name
  engine_version                      = var.engine_version
  allocated_storage                   = var.allocated_storage
  storage_type                        = var.storage_type
  username                            = var.db_username
  password                            = random_password.db_password.result
  publicly_accessible                 = var.publicly_accessible
  multi_az                            = var.multi_az
  backup_retention_period             = var.retention_period
  auto_minor_version_upgrade          = var.auto_minor_version_upgrade
  db_subnet_group_name                = aws_db_subnet_group.example1.name
  vpc_security_group_ids              = [module.vpc_module.security_group.id]
  iam_database_authentication_enabled = true
  tags = {
    Name        = "${var.db_name}-mysql"
    Environment = var.environment
  }
}

# PostgreSQL Database Instance
resource "aws_db_instance" "postgres_instance" {
  count                               = var.engine_name == "PostgreSQL" ? 1 : 0
  identifier                          =  var.db_name
  instance_class                      = var.instance_type
  engine                              = var.engine_name
  engine_version                      = var.engine_version
  allocated_storage                   = var.allocated_storage
  storage_type                        = var.storage_type
  username                            = var.db_username
  password                            = random_password.db_password.result
  publicly_accessible                 = var.publicly_accessible
  multi_az                            = var.multi_az
  backup_retention_period             = var.retention_period
  auto_minor_version_upgrade          = var.auto_minor_version_upgrade
  db_subnet_group_name                = aws_db_subnet_group.example1.name
  vpc_security_group_ids              = [module.vpc_module.security_group.id]
  iam_database_authentication_enabled = true
  tags = {
    Name        = "${var.db_name}-postgres"
    Environment = var.environment
  }
}

# Microsoft SQL Server Database Instance
resource "aws_db_instance" "mssql_instance" {
  count                               = var.mssql_instance ? 1 : 0
  identifier                          = var.db_name
  instance_class                      = var.instance_type
  engine                              = var.engine_name
  engine_version                      = var.engine_version
  allocated_storage                   = var.allocated_storage
  storage_type                        = var.storage_type
  username                            = var.db_username
  password                            = random_password.db_password.result
  publicly_accessible                 = var.publicly_accessible
  multi_az                            = var.multi_az
  backup_retention_period             = var.retention_period
  auto_minor_version_upgrade          = var.auto_minor_version_upgrade
  db_subnet_group_name                = aws_db_subnet_group.example1.name
  vpc_security_group_ids              = [module.vpc_module.security_group.id]
  iam_database_authentication_enabled = true
  tags = {
    Name        = "${var.db_name}-mssql"
    Environment = var.environment
  }
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
        Resource = "*"
      }
    ]
  })
}

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

resource "random_password" "db_password" {
  length           = var.password_length
  special          = var.password_format
  override_special = "!#$%&()*+,-./:;<=>?@[\\]^_`{|}~"
}


resource "random_password" "iam_user_passwords" {
  for_each = local.users

  length           = var.password_length
  special          = var.password_format
  override_special = "!#$%&()*+,-./:;<=>?@[\\]^_`{|}~"
}

resource "aws_secretsmanager_secret" "db_credentials" {
  name        = "db_credentials_${var.db_name}"
  description = "Database credentials for ${var.db_name}"
}

resource "aws_secretsmanager_secret_version" "db_credentials_version" {
  secret_id   = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = var.db_username
    password = random_password.db_password.result
  })
}

resource "aws_iam_user" "users" {
  for_each = local.users

  name = each.value
}

resource "aws_iam_user_policy_attachment" "user_policy_attachments" {
  for_each = local.iam_users_policies

  user       = each.value
  policy_arn = aws_iam_policy.rds_access_policy.arn
}
