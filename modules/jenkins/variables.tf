variable "namespace"             { type = string default = "jenkins" }
variable "release_name"          { type = string default = "jenkins" }
variable "chart_version"         { type = string default = "5.4.3" } # bitnami/jenkins
variable "admin_user"            { type = string default = "admin" }
variable "admin_password"        { type = string }
variable "values_yaml_overrides" { type = string } # file() content
