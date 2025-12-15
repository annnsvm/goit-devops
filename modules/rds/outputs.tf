output "db_endpoint" {
  value       = var.use_aurora ? aws_rds_cluster.this[0].endpoint : aws_db_instance.this[0].address
  description = "Endpoint до БД"
}

output "db_reader_endpoint" {
  value       = var.use_aurora ? aws_rds_cluster.this[0].reader_endpoint : null
  description = "Reader endpoint (Aurora)"
}

output "db_port"            { value = var.db_port }
output "db_username"        { value = var.username sensitive = true }
output "security_group_id"  { value = aws_security_group.this.id }
output "db_subnet_group_name" { value = aws_db_subnet_group.this.name }
output "parameter_group_name" {
  value = var.use_aurora ? aws_rds_cluster_parameter_group.this[0].name : aws_db_parameter_group.this[0].name
}
