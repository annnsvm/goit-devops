locals {
  tags = {
    Environment = "final-project"
    Project     = "goit-devops"
  }
  region = "eu-north-1"
}

provider "aws" {
  region = local.region
}

module "vpc" {
  source             = "./modules/vpc/"
  vpc_cidr_block     = "10.0.0.0/16"
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets    = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  availability_zones = ["eu-north-1a", "eu-north-1b", "eu-north-1c"]
  vpc_name           = "${local.tags.Environment}-vpc"
  tags               = local.tags
}

module "ecr" {
  source       = "./modules/ecr/"
  ecr_name     = "django-app"
  scan_on_push = true
  tags         = local.tags
}

module "eks" {
  source        = "./modules/eks"
  cluster_name  = "eks-cluster-${local.tags.Environment}"
  subnet_ids    = module.vpc.private_subnets
  instance_type = "t3.medium"
  desired_size  = 2
  max_size      = 3
  min_size      = 1
  tags          = local.tags
}

module "secrets_provider" {
  count           = var.enable_platform ? 1 : 0
  source          = "./modules/secrets-provider"
  db_name         = var.db_name
  db_username     = var.db_username
  db_password     = var.db_password
  github_pat      = var.github_pat
  github_user     = var.github_user
  github_repo_url = var.github_repo_url

  tags = local.tags
}

data "aws_eks_cluster" "eks" {
  name = module.eks.eks_cluster_name

  depends_on = [module.eks]
}

data "aws_eks_cluster_auth" "eks" {
  name = module.eks.eks_cluster_name

  depends_on = [module.eks]
}

provider "kubernetes" {
  alias                  = "eks"
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token
}

provider "helm" {
  alias = "eks"
  kubernetes = {
    host                   = data.aws_eks_cluster.eks.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.eks.token
  }
}

module "rds" {
  count  = var.enable_platform ? 1 : 0
  source = "./modules/rds/"

  name                  = "${local.tags.Environment}-db"
  use_aurora            = false
  aurora_instance_count = 2

  # --- RDS-only ---
  engine                     = "postgres"
  engine_version             = "17.2"
  parameter_group_family_rds = "postgres17"

  # Common
  instance_class          = "db.t3.medium"
  allocated_storage       = 20
  db_secret_arn           = module.secrets_provider[0].db_secret_arn
  subnet_private_ids      = module.vpc.private_subnets
  subnet_public_ids       = module.vpc.public_subnets
  publicly_accessible     = true
  vpc_id                  = module.vpc.vpc_id
  multi_az                = true
  backup_retention_period = 7
  parameters = {
    max_connections            = "200"
    log_min_duration_statement = "500"
  }

  tags = local.tags

  depends_on = [module.secrets_provider[0]]
}

module "jenkins" {
  count                     = var.enable_platform ? 1 : 0
  source                    = "./modules/jenkins/"
  cluster_name              = module.eks.eks_cluster_name
  oidc_provider_arn         = module.eks.oidc_provider_arn
  oidc_provider_url         = module.eks.oidc_provider_url
  github_secret_arn = module.secrets_provider[0].github_secret_arn

  providers = {
    helm       = helm.eks
    kubernetes = kubernetes.eks
  }

  depends_on = [module.eks]

  tags = local.tags
}

module "argo_cd" {
  count                     = var.enable_platform ? 1 : 0
  source                    = "./modules/argo-cd/"
  namespace                 = "argocd"
  name                      = "argo-cd"
  chart_version             = "5.46.4"
  db_host                   = module.rds[0].db_host
  app_image_repo            = module.ecr.repository_url
  github_secret_arn = module.secrets_provider[0].github_secret_arn
  db_secret_arn = module.secrets_provider[0].db_secret_arn

  providers = {
    helm       = helm.eks
    kubernetes = kubernetes.eks
  }

  depends_on = [module.eks]
}

module "monitoring" {
  count                     = var.enable_platform ? 1 : 0
  source = "./modules/monitoring"
  providers = {
    helm       = helm.eks
    kubernetes = kubernetes.eks
  }
  depends_on = [ module.eks ]
  tags = local.tags
}
