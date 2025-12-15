output "repository_url" {
  description = "URL of the created ECR repository"
  value       = aws_ecr_repository.ecr.repository_url
}