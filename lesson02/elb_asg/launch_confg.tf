variable "instance_type" {
  default = "t2.micro"
}

variable "key_name" {
  default = "wz_interview_key"
}

variable "associate_public_ip_address" {
  default = false
}

variable "iam_role" {
  default = ""
}
