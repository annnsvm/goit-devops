variable "grafana_admin_user" {
  type    = string
  default = "admin"
}
variable "grafana_admin_password" {
  type    = string
  default = "some-password"
}
variable "namespace" {
  type = string
  default = "monitoring"
}
variable "tags" {
  type    = map(string)
  default = {}
}
