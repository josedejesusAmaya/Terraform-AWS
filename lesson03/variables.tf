variable "aws_region" {
}

variable "metadata" {
  type        = map(string)
  description = "appname is used as the stack identyfier, appversion is the nginx docker tag"

  default = {
    appname    = "sample-app"
    appversion = "latest"
  }
}

variable "env" {
}

variable "tags" {
  type = map(string)
}

