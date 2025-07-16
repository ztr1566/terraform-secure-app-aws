terraform {
  backend "s3" {
    bucket         = "backend-terraform-project-10"
    key            = "dev/terraform.tfstate"
    region         = "eu-west-3"
    dynamodb_table = "terraform-locks"
  }
}