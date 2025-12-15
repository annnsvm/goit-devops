resource "helm_release" "argo_cd" {
  name       = var.name
  namespace  = var.namespace
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.chart_version

  values = [
    file("${path.module}/values.yaml")
  ]

  create_namespace = true
}

resource "helm_release" "argo_apps" {
  name       = "${var.name}-apps"

  chart      = "${path.module}/charts"
  namespace  = var.namespace
  create_namespace = false

  values = [
    file("${path.module}/values.yaml"),
    yamlencode({
      config = {
        POSTGRES_HOST = var.db_host
        DATABASE_HOST = var.db_host
      },
      image = {
        repository = var.app_image_repo
      }
    })
  ]

  depends_on = [helm_release.argo_cd]
}
