terraform {
  backend "s3" {
    bucket         = "your-unique-tfstate-bucket"  
    key            = "lesson-7/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
