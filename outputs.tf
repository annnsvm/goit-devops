output "ECR_repository_url" {
  description = "URL of the created ECR repository"
  value       = var.enable_platform ? module.ecr.repository_url : "none"
}

output "oidc_provider_arn" {
  description = "OIDC Provider ARN"
  value       = module.eks.oidc_provider_arn
}

output "oidc_provider_url" {
  description = "OIDC Provider URL"
  value       = module.eks.oidc_provider_url
}

#-------------Jenkins-----------------
output "jenkins_release" {
  value = var.enable_platform ?  module.jenkins[0].jenkins_release_name : "none"
}

output "jenkins_namespace" {
  value = var.enable_platform ? module.jenkins[0].jenkins_namespace : "none"
}

#-------------DB-----------------
output "postgres_endpoint" {
  description = "DB instance endpoint"
  value       = var.enable_platform ? module.rds[0].db_instance_endpoint : "none"
}
