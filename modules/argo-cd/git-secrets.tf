data "aws_secretsmanager_secret_version" "github_creds" {
  secret_id     = var.github_secret_arn
  version_stage = "AWSCURRENT"
}

locals {
  gh = {
    for k, v in jsondecode(data.aws_secretsmanager_secret_version.github_creds.secret_string) :
    k => tostring(v)
  }
}

resource "kubernetes_secret" "argocd_repo" {
  metadata {
    name      = "repo-goit-devops"
    namespace = var.namespace
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }

  data = {
    type     = "git"
    url      = "https://github.com/KryvkoSergii/goit-devops.git"
    username = local.gh.user
    password = local.gh.pat
  }

  type = "Opaque"

  depends_on = [ helm_release.argo_cd ]
}