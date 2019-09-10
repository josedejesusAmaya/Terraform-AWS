variable "min_size" {
  default = 1
}

variable "max_size" {
  default = 1
}

variable "health_check_grace_period" {
  default = 500
}

variable "default_cooldown" {
  default = 700
}

variable "desired_capacity" {
  default = 1
}

variable "metrics_granularity" {
  default = "1Minute"
}

variable "health_check_type" {
  default = "ELB"
}

