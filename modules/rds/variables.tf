variable "name" { description = "Базове ім'я ресурсів"; type = string }
variable "use_aurora" { description = "true → Aurora; false → RDS instance"; type = bool default = false }
variable "engine" { description = "postgres | mysql | aurora-postgresql | aurora-mysql ..."; type = string default = "postgres" }
variable "engine_version" { description = "Версія рушія"; type = string default = "14.6" }
variable "instance_class" { description = "db.t3.medium, db.r6g.large, ..."; type = string default = "db.t3.medium" }
variable "username" { type = string default = "admin" }
variable "password" { type = string sensitive = true }
variable "subnet_ids" { type = list(string) }
variable "vpc_id" { type = string }
variable "allocated_storage" { type = number default = 20 }
variable "multi_az" { type = bool default = false }
variable "db_port" { type = number default = 5432 }
variable "parameter_group_family" { type = string default = "postgres14" }
variable "cluster_parameter_group_family" { type = string default = "aurora-postgresql14" }
variable "allowed_cidr_blocks" { type = list(string) default = [] }
variable "allowed_security_group_ids" { type = list(string) default = [] }
variable "apply_immediately" { type = bool default = true }
variable "backup_retention_period" { type = number default = 7 }
variable "deletion_protection" { type = bool default = false }
variable "skip_final_snapshot" { type = bool default = true }
variable "preferred_backup_window" { type = string default = null }
variable "preferred_maintenance_window" { type = string default = null }
variable "parameters" {
  type = list(object({
    name         = string
    value        = string
    apply_method = optional(string, "immediate")
  }))
  default = []
}
variable "tags" { type = map(string) default = {} }
