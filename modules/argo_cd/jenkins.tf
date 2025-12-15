resource "kubernetes_namespace" "ns" {
  metadata { name = var.namespace }
}

resource "helm_release" "argo_cd" {
  name       = var.release_name
  namespace  = var.namespace
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.chart_version
  values     = [ var.values_yaml_overrides ]
  depends_on = [kubernetes_namespace.ns]
}

resource "helm_release" "apps" {
  name      = "apps"
  namespace = var.namespace
  chart     = "${path.module}/charts"

  values = [
    yamlencode({
      applications = [{
        name           = var.app_name
        namespace      = var.app_namespace
        repoURL        = var.app_repo_url
        targetRevision = var.app_repo_revision
        chartPath      = var.app_chart_path
        autoSync       = var.auto_sync
      }]
    })
  ]

  depends_on = [helm_release.argo_cd]
}
