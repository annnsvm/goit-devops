variable "cluster_name"   { type = string default = "project-eks" }
variable "namespace"      { type = string default = "argocd" }
variable "release_name"   { type = string default = "argo-cd" }
variable "chart_version"  { type = string default = "7.6.12" } # argo/argo-cd
variable "values_yaml_overrides" { type = string }

# App settings
variable "app_repo_url"     { type = string }  # Git-репо з твоїм Helm chart (django-app)
variable "app_repo_revision"{ type = string default = "main" }
variable "app_chart_path"   { type = string default = "charts/django-app" }
variable "app_name"         { type = string default = "django-app" }
variable "app_namespace"    { type = string default = "default" }
variable "auto_sync"        { type = bool   default = true }
