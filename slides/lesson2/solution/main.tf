// Configure AWS Cloud provider
provider "aws" {
  region = var.aws_region
}

# terraform {
#  backend "s3" {
#    bucket = "your-bucket-name-here"
#    region = "us-east-2"
#  }
#}

#--------------------------------------------------------------
# default VPC
# https://www.terraform.io/docs/providers/aws/r/default_vpc.html
#--------------------------------------------------------------
resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

#===========================================
#  Elastic Load Balancer
#===========================================
resource "aws_elb" "elb" {
  name = "${var.elb_name}-elb-${var.env}"
  subnets         = data.aws_subnet_ids.vpc_subnets.ids
  security_groups = [aws_security_group.web.id]
  tags = merge(
    var.tags,
    {
      "Name" = format("%s", var.elb_name)
    },
  )
  dynamic "listener" {
    for_each = [var.elb_listener]
    content {
      instance_port      = lookup(listener.value, "instance_port", null)
      instance_protocol  = lookup(listener.value, "instance_protocol", null)
      lb_port            = lookup(listener.value, "lb_port", null)
      lb_protocol        = lookup(listener.value, "lb_protocol", null)
    }
  }
  dynamic "health_check" {
    for_each = [var.elb_health_check]
    content {
      healthy_threshold   = lookup(health_check.value, "healthy_threshold", null)
      interval            = lookup(health_check.value,"interval", null)
      target              = lookup(health_check.value,"target", null)
      timeout             = lookup(health_check.value,"timeout", null)
      unhealthy_threshold = lookup(health_check.value,"unhealthy_threshold", null)
    }
  }
  cross_zone_load_balancing   = var.cross_zone_load_balancing
  connection_draining         = var.connection_draining
  connection_draining_timeout = var.connection_draining_timeout
  internal                    = var.internal
}

#===========================================
#  Elastic Load Balancer
#===========================================

resource "aws_route53_zone" "tf-workshop" {
  name = var.domain
}

resource "aws_route53_record" "dns_web" {
  zone_id = aws_route53_zone.tf-workshop.zone_id
  name    = "my-lb-example.${var.domain}"
  type    = "A"

  alias {
    name                   = aws_elb.elb.dns_name
    zone_id                = aws_elb.elb.zone_id
    evaluate_target_health = false
  }
}

#--------------------------------------------------------------
# Security Group
#--------------------------------------------------------------
resource "aws_security_group" "web" {
  name_prefix = "web"
  description = "Allow web traffic"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#--------------------------------------------------------------
# Launch configuration
#--------------------------------------------------------------
resource "aws_launch_configuration" "lc" {
  name_prefix                 = "${var.metadata["appname"]}-${var.env}-lc-${var.metadata["appversion"]}-"
  image_id                    = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  security_groups             = [aws_security_group.web.id]
  user_data                   = data.template_file.deploy_sh.rendered
  associate_public_ip_address = var.associate_public_ip_address
  spot_price                  = "0.02"

  lifecycle {
    create_before_destroy = true
  }
}

#===========================================
#  Auto scaling Group
#===========================================
resource "aws_autoscaling_group" "asg" {
  name_prefix          = "${var.metadata["appname"]}-${var.env}-asg-${var.metadata["appversion"]}-"
  launch_configuration = aws_launch_configuration.lc.name
  # availability_zones        = data.aws_availability_zones.available.zone_ids
  load_balancers            = [aws_elb.elb.id]
  health_check_type         = var.health_check_type
  health_check_grace_period = var.health_check_grace_period
  default_cooldown          = var.default_cooldown
  min_size                  = var.min_size
  max_size                  = var.max_size
  wait_for_elb_capacity     = var.min_size
  desired_capacity          = var.desired_capacity
  vpc_zone_identifier = data.aws_subnet_ids.vpc_subnets.ids

  //TAGS propagated to each EC2 instance
  tags = [
    {
      "key"                 = "Name"
      "value"               = "${var.metadata["appname"]}-${var.env}-ec2-${var.metadata["appversion"]}"
      "propagate_at_launch" = true
    },
  ]

  lifecycle {
    create_before_destroy = true
  }
  # A maximum duration that Terraform should wait for ASG instances to be healthy before timing out.
  # wait_for_capacity_timeout = "20m"
  #
  # autoscaling group metrics as a group 
  # https://docs.aws.amazon.com/autoscaling/ec2/APIReference/API_EnableMetricsCollection.html
  #
  # metrics_granularity       = "${var.metrics_granularity}"
  # all metrics https://docs.aws.amazon.com/autoscaling/ec2/userguide/as-instance-monitoring.html
  # enabled_metrics = [
  #   "GroupDesiredCapacity",
  #   "GroupInServiceInstances",
  #   "GroupMaxSize",
  #   "GroupMinSize",
  #   "GroupPendingInstances",
  #   "GroupStandbyInstances",
  #   "GroupTerminatingInstances",
  #   "GroupTotalInstances",
  # ]
}

