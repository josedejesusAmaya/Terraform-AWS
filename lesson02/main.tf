// Configure AWS Cloud provider
provider "aws" {
  region = var.aws_region
}

# If you prefer, you can store the Terraform state in S3
# https://www.terraform.io/docs/backends/types/s3.html
# terraform {
#   backend "s3" {
#     region = "us-east-2"
#   }
# }

#--------------------------------------------------------------
# default VPC
# https://www.terraform.io/docs/providers/aws/r/default_vpc.html
#--------------------------------------------------------------
resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}
