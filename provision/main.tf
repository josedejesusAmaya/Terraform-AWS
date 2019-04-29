provider "aws" {
  profile = "interviews-provision"
  region  = "${var.aws_region}"
}

terraform {
  backend "s3" {
    bucket = "wizeline-academy-terraform"
    key    = "terraform-academy/terraform.tfstate"
    region = "us-east-2"
  }
}

variable "aws_region" {
  default = "us-east-2"
}

variable "tf_state_bucket" {
  default = "wizeline-academy-terraform"
}

variable "total_users" {
  default = "5"
}

variable "pgp_key" {
  default = "sortigoza"
}

# Since we will duplicate this block, leave erc_name without var
module "users" {
  source = "./iam-users"

  total_users     = "${var.total_users}"
  tf_state_bucket = "${var.tf_state_bucket}"
  aws_region      = "${var.aws_region}"
  pgp_key         = "${var.pgp_key}"
}

output "iam_ids" {
  value = "${module.users.iam_ids}"
}

output "iam_keys" {
  value = "${module.users.iam_keys}"
}
