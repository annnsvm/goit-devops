variable "namespace"             { type = string default = "argocd" }
variable "release_name"          { type = string default = "argo-cd" }
variable "chart_version"         { type = string default = "7.6.12" }
variable "values_yaml_overrides" { type = string }
variable "app_repo_url"          { type = string }  # Git URL до репо з чартом
variable "app_repo_revision"     { type = string default = "main" }
variable "app_chart_path"        { type = string default = "charts/django-app" }
variable "app_name"              { type = string default = "django-app" }
variable "app_namespace"         { type = string default = "default" }
variable "auto_sync"             { type = bool   default = true }
