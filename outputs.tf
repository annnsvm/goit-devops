output "backend_bucket"           { value = module.s3_backend.bucket_id }
output "backend_dynamodb_table"   { value = module.s3_backend.table_name }

output "vpc_id"                   { value = module.vpc.vpc_id }
output "public_subnet_ids"        { value = module.vpc.public_subnet_ids }
output "private_subnet_ids"       { value = module.vpc.private_subnet_ids }

output "ecr_repository_url"       { value = module.ecr.repository_url }

output "eks_cluster_name"         { value = module.eks.cluster_name }
output "eks_cluster_endpoint"     { value = module.eks.cluster_endpoint }

output "rds_endpoint"             { value = module.rds.db_endpoint }
output "rds_port"                 { value = module.rds.db_port }
output "rds_security_group_id"    { value = module.rds.security_group_id }

output "jenkins_namespace"        { value = module.jenkins.jenkins_namespace }
output "argocd_namespace"         { value = module.argo_cd.argocd_namespace }
