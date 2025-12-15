data "aws_secretsmanager_secret_version" "db-rds" {
  secret_id     = var.db_secret_arn
  version_stage = "AWSCURRENT"
}