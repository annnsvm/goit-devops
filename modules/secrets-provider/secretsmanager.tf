resource "aws_secretsmanager_secret" "db_creds" {
  name                    = "db/creds"
  description             = "RDS credentials"
  recovery_window_in_days = 7
  tags = merge(var.tags, { Component   = "database" })
}

resource "aws_secretsmanager_secret_version" "db_creds_v1" {
  secret_id = aws_secretsmanager_secret.db_creds.id
  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password
    name     = var.db_name
  })
}

resource "aws_secretsmanager_secret" "github_creds" {
  name                    = "github/creds"
  description             = "Github credentials"
  recovery_window_in_days = 7
  tags = merge(var.tags, { Component = "github" })
}

resource "aws_secretsmanager_secret_version" "github_creds_v1" {
  secret_id = aws_secretsmanager_secret.github_creds.id
  secret_string = jsonencode({
    pat      = var.github_pat
    user     = var.github_user
    repo_url = var.github_repo_url
  })
}
