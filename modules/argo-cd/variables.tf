variable "name" {
  description = "Name of Helm-release"
  type        = string
  default     = "argo-cd"
}

variable "namespace" {
  description = "K8s namespace for Argo CD"
  type        = string
  default     = "argocd"
}

variable "chart_version" {
  description = "Version of Argo CD chart"
  type        = string
  default     = "5.46.4" 
}

variable "db_host" {
  description = "DB host for client connetion"
  type = string
}

variable "app_image_repo" {
  description = "App image repo"
  type = string
}

variable "github_secret_arn" {
  type = string
}

variable "db_secret_arn" {
  type = string
}