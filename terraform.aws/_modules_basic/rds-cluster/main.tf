
resource "aws_rds_cluster" "sac_rds_cluster" {
  cluster_identifier        = "sac-testing-rds-cluster"
  database_name             = "sacrdsdatabase"
  engine                    = "aurora-mysql"
  master_username           = "sacMasterUsername"
  master_password           = "randomlydecidedpassword41characters"
  final_snapshot_identifier = "DELETE"
  skip_final_snapshot       = true
  deletion_protection       = false
  db_subnet_group_name      = aws_db_subnet_group.sac_rds_subnet_group.name
  backup_retention_period   = 7
  engine_version            = "8.0.mysql_aurora.3.03.0"
  storage_encrypted                   = false
  iam_database_authentication_enabled = false
}

resource "aws_db_option_group" "sac_rds_option_group" {
  name                     = "sac-rds-option-group"
  option_group_description = "Terraform Option Group"
  engine_name              = "mysql"
  major_engine_version     = "8.0"
}

resource "aws_db_parameter_group" "sac_rds_parameter_group" {
  name   = "sac-rds-param-group"
  family = "mysql5.6"
  parameter {
    name  = "character_set_server"
    value = "utf8"
  }
}

resource "aws_db_proxy" "sac_rds_db_proxy" {
  name           = "sac-rds-db-proxy"
  role_arn       = aws_iam_role.db_proxy_role.arn
  vpc_subnet_ids = [aws_subnet.rds_subnet_1.id, aws_subnet.rds_subnet_2.id]
  engine_family  = "MYSQL"
  debug_logging  = true
  require_tls    = false
  auth {
    secret_arn = aws_secretsmanager_secret.sac_secrets_manager.arn
    iam_auth = "DISABLED"
  }
}

resource "aws_db_subnet_group" "sac_rds_subnet_group" {
  name        = "sac-rds-subnet-group"
  description = "Our main group of subnets"
  subnet_ids  = [aws_subnet.rds_subnet_1.id, aws_subnet.rds_subnet_2.id]
}
