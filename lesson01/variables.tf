variable "tags" {
  default = {
    Terraform  = true
    Service    = "web"
    Customer   = "Stark Industries"
    Owner      = "Wizeline"
    Maintainer = "devops@wizeline.com"
  }

  description = "Tags to set in the resources"
  type        = map(string)
}

variable "app_name" {
  default     = "nginx"
  description = "The application name, this must match with the name of the docker image"
  type        = string
}

variable "app_version" {
  default     = "1.16"
  description = "The version of the application name, this must match with the name of the docker tag"
  type        = string
}

variable "domain" {
  default     = "academy.wizeline.dev"
  description = "The domain name to use"
  type        = string
}

