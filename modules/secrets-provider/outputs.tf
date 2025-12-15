output "db_secret_arn" {
  value     = aws_secretsmanager_secret.db_creds.arn
  sensitive = true
}

output "github_secret_arn" {
  value     = aws_secretsmanager_secret.github_creds.arn
  sensitive = true
}