variable "cluster_name"     { type = string default = "project-eks" }
variable "namespace"        { type = string default = "jenkins" }
variable "release_name"     { type = string default = "jenkins" }
variable "chart_version"    { type = string default = "5.4.3" } # bitnami/jenkins версія
variable "admin_user"       { type = string default = "admin" }
variable "admin_password"   { type = string }
variable "ecr_account_id"   { type = string }
variable "ecr_region"       { type = string }
variable "values_yaml_overrides" { type = string }
