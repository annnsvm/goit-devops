terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = { source = "hashicorp/aws", version = ">= 5.0" }
  }
}

provider "aws" {
  region = var.aws_region
}

variable "aws_region" { type = string default = "us-west-2" }

# --- Твої попередні модулі (s3-backend, vpc, ecr, eks) ---
module "s3_backend" {
  source      = "./modules/s3-backend"
  bucket_name = var.backend_bucket_name
  table_name  = var.backend_table_name
  tags        = var.tags
}

module "vpc" {
  source             = "./modules/vpc"
  vpc_cidr_block     = var.vpc_cidr_block
  public_subnets     = var.public_subnets
  private_subnets    = var.private_subnets
  availability_zones = var.availability_zones
  vpc_name           = var.vpc_name
  tags               = var.tags
}

module "ecr" {
  source       = "./modules/ecr"
  ecr_name     = var.ecr_name
  scan_on_push = true
  tags         = var.tags
}

module "eks" {
  source              = "./modules/eks"
  cluster_name        = var.cluster_name
  subnet_ids          = concat(module.vpc.public_subnet_ids, module.vpc.private_subnet_ids)
  node_instance_types = ["t3.medium"]
  desired_size        = 2
  min_size            = 2
  max_size            = 4
  tags                = var.tags
}

# --- Jenkins через Helm ---
module "jenkins" {
  source                  = "./modules/jenkins"
  namespace               = "jenkins"
  release_name            = "jenkins"
  chart_version           = "5.4.3" # приклад: bitnami/jenkins
  admin_user              = "admin"
  admin_password          = "ChangeMe123!"
  ecr_account_id          = var.account_id
  ecr_region              = var.aws_region
  values_yaml_overrides   = file("${path.module}/modules/jenkins/values.yaml")
  depends_on              = [module.eks]
}

# --- Argo CD через Helm ---
module "argo_cd" {
  source                = "./modules/argo_cd"
  namespace             = "argocd"
  release_name          = "argo-cd"
  chart_version         = "7.6.12"  # приклад: argo/argo-cd
  app_repo_url          = var.app_repo_url      # репо з Helm-чартом django-app
  app_repo_revision     = "main"
  app_chart_path        = "charts/django-app"
  app_name              = "django-app"
  app_namespace         = "default"
  auto_sync             = true
  values_yaml_overrides = file("${path.module}/modules/argo_cd/values.yaml")
  depends_on            = [module.eks]
}

# ---- Variables you may already have ----
variable "account_id"          { type = string }
variable "backend_bucket_name" { type = string }
variable "backend_table_name"  { type = string }
variable "vpc_cidr_block"      { type = string default = "10.0.0.0/16" }
variable "public_subnets"      { type = list(string) default = ["10.0.1.0/24","10.0.2.0/24","10.0.3.0/24"] }
variable "private_subnets"     { type = list(string) default = ["10.0.4.0/24","10.0.5.0/24","10.0.6.0/24"] }
variable "availability_zones"  { type = list(string) default = ["us-west-2a","us-west-2b","us-west-2c"] }
variable "vpc_name"            { type = string default = "project-vpc" }
variable "ecr_name"            { type = string default = "project-django" }
variable "cluster_name"        { type = string default = "project-eks" }
variable "app_repo_url"        { type = string } # <git url до репозиторію, де лежить charts/django-app>

variable "tags" {
  type = map(string)
  default = { Project = "project", Managed = "Terraform" }
}
