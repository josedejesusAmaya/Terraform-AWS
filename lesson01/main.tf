// Configure AWS Cloud provider
provider "aws" {
  region = "us-east-2"
}

terraform {
  backend "s3" {
    bucket = "wizeline-academy-terraform"
    region = "us-east-2"
  }
}

