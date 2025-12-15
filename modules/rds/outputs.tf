output "db_instance_endpoint" {
  description = "DB instance endpoint"
  value       =  var.use_aurora ? aws_rds_cluster.aurora[0].endpoint : aws_db_instance.standard[0].endpoint
}

output "db_host" {
  description = "DB instance endpoint"
  value       =  var.use_aurora ? aws_rds_cluster.aurora[0].endpoint : aws_db_instance.standard[0].endpoint
}