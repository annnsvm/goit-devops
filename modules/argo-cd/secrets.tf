data "aws_secretsmanager_secret_version" "db" {
  secret_id     = var.db_secret_arn
  version_stage = "AWSCURRENT"
}

locals {
  db = {
    for k, v in jsondecode(data.aws_secretsmanager_secret_version.db.secret_string) :
    k => tostring(v)
  }
}

resource "kubernetes_secret" "django_db" {
  metadata {
    name      = "django-db"
    namespace = var.namespace
  }

  data = {
    POSTGRES_NAME     = local.db.name
    POSTGRES_USER     = local.db.username
    POSTGRES_PASSWORD = local.db.password
  }

  type = "Opaque"
}
