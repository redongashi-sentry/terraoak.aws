
resource "aws_db_instance" "sac_db_instance" {
  db_name                   = "sacDatabaseName"
  identifier                = "sac-testing-db-instance"
  allocated_storage         = 10
  instance_class            = "db.t3.micro"
  username                  = "sacRDSInstanceName"
  password                  = "randomPasswordThatFollowstheCharLimit"
  engine                    = "mysql"
  skip_final_snapshot       = true
  final_snapshot_identifier = "DELETE"
  db_subnet_group_name      = aws_db_subnet_group.sac_rds_subnet_group.name
  deletion_protection       = false
  backup_retention_period   = 0
  engine_version            = "8.0"
  iam_database_authentication_enabled = false
  multi_az            = false
  publicly_accessible = true
  storage_encrypted   = false
}

resource "aws_db_proxy_default_target_group" "sac_proxy_target_group" {
  db_proxy_name = aws_db_proxy.sac_rds_db_proxy.name
}

resource "aws_db_proxy_target" "sac_instance_proxy_target" {
  db_proxy_name          = aws_db_proxy.sac_rds_db_proxy.name
  target_group_name      = aws_db_proxy_default_target_group.sac_proxy_target_group.name
  db_instance_identifier = aws_db_instance.sac_db_instance.id
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
