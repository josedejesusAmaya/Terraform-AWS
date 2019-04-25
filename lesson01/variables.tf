variable "tags" {
  default = {
    Terraform  = true
    Service    = "web"
    Customer   = "Stark Industries"
    Owner      = "Wizeline"
    Maintainer = "devops@wizeline.com"
  }

  description = "Tags to set in the resources"
  type        = "map"
}
