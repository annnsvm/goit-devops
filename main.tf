terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = { source = "hashicorp/aws", version = ">= 5.0" }
  }
}

provider "aws" {
  region = var.aws_region
}

# -------- Variables --------
variable "aws_region"           { type = string default = "us-west-2" }
variable "account_id"           { type = string }  # 12-значний AWS Account ID

variable "backend_bucket_name"  { type = string default = "your-unique-bucket" }
variable "backend_table_name"   { type = string default = "terraform-locks" }

variable "vpc_cidr_block"       { type = string default = "10.0.0.0/16" }
variable "public_subnets"       { type = list(string) default = ["10.0.1.0/24","10.0.2.0/24","10.0.3.0/24"] }
variable "private_subnets"      { type = list(string) default = ["10.0.4.0/24","10.0.5.0/24","10.0.6.0/24"] }
variable "availability_zones"   { type = list(string) default = ["us-west-2a","us-west-2b","us-west-2c"] }
variable "vpc_name"             { type = string default = "project-vpc" }

variable "ecr_name"             { type = string default = "project-django" }

variable "cluster_name"         { type = string default = "project-eks" }
variable "node_instance_types"  { type = list(string) default = ["t3.medium"] }
variable "desired_size"         { type = number default = 2 }
variable "min_size"             { type = number default = 2 }
variable "max_size"             { type = number default = 4 }

# RDS defaults
variable "rds_name"             { type = string default = "project-db" }
variable "use_aurora"           { type = bool   default = false }
variable "rds_engine"           { type = string default = "postgres" }           # або aurora-postgresql
variable "rds_engine_version"   { type = string default = "14.6" }
variable "rds_instance_class"   { type = string default = "db.t3.medium" }
variable "rds_username"         { type = string default = "admin" }
variable "rds_password"         { type = string } # sensitive in module
variable "rds_multi_az"         { type = bool   default = false }

variable "tags" { type = map(string) default = { Project = "project", Managed = "Terraform" } }

# -------- Modules wiring --------
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
  node_instance_types = var.node_instance_types
  desired_size        = var.desired_size
  min_size            = var.min_size
  max_size            = var.max_size
  tags                = var.tags
}

module "rds" {
  source                          = "./modules/rds"
  name                            = var.rds_name
  use_aurora                      = var.use_aurora
  engine                          = var.rds_engine
  engine_version                  = var.rds_engine_version
  instance_class                  = var.rds_instance_class
  username                        = var.rds_username
  password                        = var.rds_password
  subnet_ids                      = module.vpc.private_subnet_ids
  vpc_id                          = module.vpc.vpc_id
  multi_az                        = var.rds_multi_az
  parameter_group_family          = "postgres14"
  cluster_parameter_group_family  = "aurora-postgresql14"
  allowed_cidr_blocks             = []      # за потреби додай CIDR
  allowed_security_group_ids      = []      # за потреби дозволи іншим SG
  tags                            = var.tags
}

module "jenkins" {
  source                = "./modules/jenkins"
  cluster_name          = var.cluster_name
  namespace             = "jenkins"
  release_name          = "jenkins"
  chart_version         = "5.4.3"
  admin_user            = "admin"
  admin_password        = "ChangeMe123!"
  values_yaml_overrides = file("${path.module}/modules/jenkins/values.yaml")
  depends_on            = [module.eks]
}

module "argo_cd" {
  source                = "./modules/argo_cd"
  cluster_name          = var.cluster_name
  namespace             = "argocd"
  release_name          = "argo-cd"
  chart_version         = "7.6.12"
  values_yaml_overrides = file("${path.module}/modules/argo_cd/values.yaml")
  app_repo_url          = "https://github.com/your-org/your-helm-repo.git"  # ← заміни
  app_repo_revision     = "main"
  app_chart_path        = "charts/django-app"
  app_name              = "django-app"
  app_namespace         = "default"
  auto_sync             = true
  depends_on            = [module.eks]
}
