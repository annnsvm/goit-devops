provider "aws" {
  region = "eu-north-1"
}

module "s3_backend" {
  source      = "./modules/s3-backend/"
  bucket_name = "goit-devops-terraform-state-bucket"
  table_name  = "goit-devops-terraform-locks"
}