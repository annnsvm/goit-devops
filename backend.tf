terraform {
  backend "s3" {
    bucket         = "your-unique-bucket"     
    key            = "project/terraform.tfstate"
    region         = "us-west-2"             
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
