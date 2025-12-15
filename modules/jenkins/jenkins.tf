resource "kubernetes_namespace" "ns" {
  metadata { name = var.namespace }
}

resource "helm_release" "jenkins" {
  name       = var.release_name
  namespace  = var.namespace
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "jenkins"
  version    = var.chart_version

  values = [
    var.values_yaml_overrides,
    yamlencode({
      controller = {
        adminUser     = var.admin_user
        adminPassword = var.admin_password
        # Увімкнемо Kubernetes agent (Jenkins k8s plugin)
        jenkinsUriPrefix = ""
      }
      agent = {
        enabled = true
      }
      rbac = { create = true }
      service = {
        type = "LoadBalancer"
      }
      resources = {
        requests = { cpu = "200m", memory = "512Mi" }
        limits   = { cpu = "1",    memory = "2Gi" }
      }
    })
  ]

  depends_on = [kubernetes_namespace.ns]
}
