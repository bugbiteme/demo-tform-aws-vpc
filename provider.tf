provider "aws" {
  access_key = var.AWS_ACCESS_KEY
  secret_key = var.AWS_SECRET_KEY
  region     = var.region

  default_tags {
    tags = {
      Environment = "Test"
      Owner       = "Westfield LLC"
      Project     = "Test Default Tags"
    }
  }
}


terraform {
  required_version = ">=0.14.9"
}