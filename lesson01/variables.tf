variable "tags" {
  default = {
    Terraform  = true
    Service    = "web"
    Customer   = "Stark Industries"
    Owner      = "Wizeline"
    Maintainer = "sre@wizeline.com"
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

variable "instance_key" {
  default     = "academy-test-lesson-01"
  description = "AWS key created to access the instance via ssh"
  type        = string
}

# Only uncomment if you have a hosted zone in Route53 and a domain
# Change the default value to your domain if you have one
# variable "domain" {
#   default     = "mydomain.com"
#   description = "The domain name to use"
#   type        = string
# }
