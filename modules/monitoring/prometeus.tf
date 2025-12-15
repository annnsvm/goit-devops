resource "helm_release" "prometheus_stack" {
  name       = "kube-prometheus"
  namespace  = var.namespace
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "55.5.0"

  create_namespace = true

  wait            = true
  timeout         = 1200
  atomic          = true
  cleanup_on_fail = true

  values = [
    yamlencode({
      grafana = {
        enabled = true
        admin = {
          userKey        = var.grafana_admin_user
          passwordKey    = var.grafana_admin_password
        }
        service = {
          type = "LoadBalancer"
        }
      }

      prometheus = {
        service = { type = "ClusterIP" }
        prometheusSpec = {
          serviceMonitorSelectorNilUsesHelmValues = false
          podMonitorSelectorNilUsesHelmValues     = false
        }
      }

      kube-state-metrics = { enabled = true }
      nodeExporter       = { enabled = true }
    })
  ]
}