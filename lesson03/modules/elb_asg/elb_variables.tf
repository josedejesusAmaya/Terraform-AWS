variable "cross_zone_load_balancing" {
  default = "true"
}

variable "connection_draining" {
  default = "true"
}

variable "connection_draining_timeout" {
  default = 100
}

variable "internal" {
  default = false
}

variable "elb_listener" {
  default = [
    {
      instance_port     = "80"
      instance_protocol = "HTTP"
      lb_port           = "80"
      lb_protocol       = "HTTP"
    },
  ]
}

variable "elb_health_check" {
  default = [
    {
      target              = "HTTP:80/"
      interval            = 30
      healthy_threshold   = 2
      unhealthy_threshold = 2
      timeout             = 5
    },
  ]
}
