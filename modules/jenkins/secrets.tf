data "aws_secretsmanager_secret_version" "github" {
  secret_id     = var.github_secret_arn
  version_stage = "AWSCURRENT"
}

resource "kubernetes_secret" "jenkins-shared" {
  metadata {
    name      = "jenkins-shared"
    namespace = var.namespace
  }
  data = try(
    { for k, v in jsondecode(data.aws_secretsmanager_secret_version.github.secret_string) : k => tostring(v) },
    { value = data.aws_secretsmanager_secret_version.github.secret_string }
  )
  type = "Opaque"
}
