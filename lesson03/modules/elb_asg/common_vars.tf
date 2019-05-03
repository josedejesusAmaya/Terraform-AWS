variable "metadata" {
  type        = "map"
  description = "appname is used as the stack id, appversion is the nginx docker tag"

  default = {
    appname    = "sample-app"
    appversion = "latest"
  }
}

variable "env" {
  description = "string for the enviroment, allowed values develop, uat, prod"
  default     = "develop"
}

variable "tags" {
  type = "map"

  default = {
    Name     = "sample-app"
    owner    = "devops@wizeline.com"
    bu       = "app"
    product  = "manager"
    preserve = "true"
    appid    = "sample-app-webapp"
  }
}
