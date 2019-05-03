variable "instance_type" {
  default = "t2.micro"
}

variable "key_name" {
  default = "devops-interviews-us-east-2"
}

variable "associate_public_ip_address" {
  default = false
}

variable "iam_role" {
  default = ""
}
