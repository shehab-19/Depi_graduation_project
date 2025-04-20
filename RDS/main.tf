data "aws_MSSQL_Server_db_instance" "Custom_MSSQL_Server" {
  engine                     = "Microsoft SQL Server" # CEV engine to be used
  engine_version             = "SQL Server 2019 15.00.4430.1.v1"     # CEV engine version to be used
  storage_type               = "gp3"
  preferred_instance_class = "db.t3.micro"
}

# The RDS instance resource requires an ARN. Look up the ARN of the KMS key.
data "aws_kms_key" "by_id" {
  key_id = "40ba7783-3c99-4b5d-94ee-8b4dc26a9bb3" # KMS key
}

resource "aws_db_instance" "example" {
  allocated_storage           = 500
  auto_minor_version_upgrade  = false                                  # Custom for SQL Server does not support minor version upgrades
  custom_iam_instance_profile = "AWSRDSCustomSQLServerInstanceProfile" # Instance profile is required for Custom for SQL Server. See: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/custom-setup-sqlserver.html#custom-setup-sqlserver.iam
  backup_retention_period     = 7
  db_subnet_group_name        = local.db_subnet_group_name # Copy the subnet group from the RDS Console
  engine                      = data.aws_rds_orderable_db_instance.custom-sqlserver.engine
  engine_version              = data.aws_rds_orderable_db_instance.custom-sqlserver.engine_version
  identifier                  = "sql-instance-demo"
  instance_class              = data.aws_rds_orderable_db_instance.custom-sqlserver.instance_class
  kms_key_id                  = data.aws_kms_key.by_id.arn
  multi_az                    = false # Custom for SQL Server does support multi-az
  password                    = "avoid-plaintext-passwords"
  storage_encrypted           = true
  username                    = "test"

  timeouts {
    create = "3h"
    delete = "3h"
    update = "3h"
  }
}