terraform {
  backend "s3" {
    bucket         = "goit-devops-terraform-state-bucket"
    key            = "final-project/terraform.tfstate"
    region         = "eu-north-1"
    dynamodb_table = "goit-devops-terraform-locks"
    encrypt        = true
  }
}
