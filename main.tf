terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# ---------- Variables ----------
variable "aws_region"         { type = string default = "us-west-2" }
variable "backend_bucket_name"{ type = string default = "your-unique-tfstate-bucket" }
variable "backend_table_name" { type = string default = "terraform-locks" }

variable "vpc_cidr_block"     { type = string       default = "10.0.0.0/16" }
variable "public_subnets"     { type = list(string) default = ["10.0.1.0/24","10.0.2.0/24","10.0.3.0/24"] }
variable "private_subnets"    { type = list(string) default = ["10.0.4.0/24","10.0.5.0/24","10.0.6.0/24"] }
variable "availability_zones" { type = list(string) default = ["us-west-2a","us-west-2b","us-west-2c"] }
variable "vpc_name"           { type = string       default = "lesson-7-vpc" }

variable "ecr_name"           { type = string default = "lesson-7-django" }
variable "scan_on_push"       { type = bool   default = true }

variable "cluster_name"       { type = string default = "lesson-7-eks" }
variable "node_instance_types"{ type = list(string) default = ["t3.medium"] }
variable "desired_size"       { type = number default = 2 }
variable "min_size"           { type = number default = 2 }
variable "max_size"           { type = number default = 4 }

variable "tags" {
  type = map(string)
  default = { Project = "lesson-7", Managed = "Terraform" }
}

# ---------- Modules ----------
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
  scan_on_push = var.scan_on_push
  tags         = var.tags
}

module "eks" {
  source            = "./modules/eks"
  cluster_name      = var.cluster_name
  subnet_ids        = concat(module.vpc.public_subnet_ids, module.vpc.private_subnet_ids)
  node_instance_types = var.node_instance_types
  desired_size      = var.desired_size
  min_size          = var.min_size
  max_size          = var.max_size
  tags              = var.tags
}
