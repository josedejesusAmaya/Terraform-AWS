#--------------------------------------------------------------
# default VPC
# https://www.terraform.io/docs/providers/aws/r/default_vpc.html
#--------------------------------------------------------------
resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

locals {
  app_name   = "${var.metadata["appname"]}-${var.env}"
  appversion = var.metadata["appversion"]
}

#--------------------------------------------------------------
# Launch configuration
#--------------------------------------------------------------
resource "aws_launch_configuration" "lc" {
  lifecycle {
    create_before_destroy = true
  }

  name_prefix     = "${local.app_name}-lc-${local.appversion}-"
  image_id        = data.aws_ami.amazon_linux.id
  instance_type   = var.instance_type
  security_groups = [aws_security_group.web.id]

  //iam_instance_profile        = "${var.iam_role}" //Optional ami role assigned to the EC2 instance
  user_data                   = data.template_file.deploy_sh.rendered
  key_name                    = var.key_name
  associate_public_ip_address = var.associate_public_ip_address
}

#===========================================
#  Auto scaling Group
#===========================================
resource "aws_autoscaling_group" "asg" {
  name_prefix          = "${local.app_name}-asg-${local.appversion}-"
  launch_configuration = aws_launch_configuration.lc.name

  # workarround for issue: https://github.com/hashicorp/terraform/issues/15978
  # if vpc_zone_identifier is used, do not use availability_zones
  # availability_zones        = ["${var.aws_availability_zones}"]
  load_balancers = [aws_elb.elb.id]

  health_check_type         = var.health_check_type
  health_check_grace_period = var.health_check_grace_period
  default_cooldown          = var.default_cooldown

  min_size = var.min_size
  max_size = var.max_size

  desired_capacity = var.desired_capacity

  # TF-UPGRADE-TODO: In Terraform v0.10 and earlier, it was sometimes necessary to
  # force an interpolation expression to be interpreted as a list by wrapping it
  # in an extra set of list brackets. That form was supported for compatibility in
  # v0.11, but is no longer supported in Terraform v0.12.
  #
  # If the expression in the following list itself returns a list, remove the
  # brackets to avoid interpretation as a list of lists. If the expression
  # returns a single list item then leave it as-is and remove this TODO comment.
  vpc_zone_identifier = [slice(data.aws_subnet_ids.vpc_subnets.ids, 0, 2)]

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

  //TAGS propagated to each EC2 instance
  tags = [
    {
      "key"                 = "Name"
      "value"               = "${local.app_name}-ec2-${local.appversion}"
      "propagate_at_launch" = true
    },
  ]

  lifecycle {
    create_before_destroy = true
  }
}

#===========================================
#  Elastic Load Balancer
#===========================================
resource "aws_elb" "elb" {
  name = "${local.app_name}-elb"
  # TF-UPGRADE-TODO: In Terraform v0.10 and earlier, it was sometimes necessary to
  # force an interpolation expression to be interpreted as a list by wrapping it
  # in an extra set of list brackets. That form was supported for compatibility in
  # v0.11, but is no longer supported in Terraform v0.12.
  #
  # If the expression in the following list itself returns a list, remove the
  # brackets to avoid interpretation as a list of lists. If the expression
  # returns a single list item then leave it as-is and remove this TODO comment.
  subnets         = [slice(data.aws_subnet_ids.vpc_subnets.ids, 0, 2)]
  security_groups = [aws_security_group.web.id]
  tags = merge(
    var.tags,
    {
      "Name" = format("%s", "${local.app_name}-elb")
    },
  )

  dynamic "listener" {
    for_each = [var.elb_listener]
    content {
      # TF-UPGRADE-TODO: The automatic upgrade tool can't predict
      # which keys might be set in maps assigned here, so it has
      # produced a comprehensive set here. Consider simplifying
      # this after confirming which keys can be set in practice.

      instance_port      = listener.value.instance_port
      instance_protocol  = listener.value.instance_protocol
      lb_port            = listener.value.lb_port
      lb_protocol        = listener.value.lb_protocol
      ssl_certificate_id = lookup(listener.value, "ssl_certificate_id", null)
    }
  }
  dynamic "health_check" {
    for_each = [var.elb_health_check]
    content {
      # TF-UPGRADE-TODO: The automatic upgrade tool can't predict
      # which keys might be set in maps assigned here, so it has
      # produced a comprehensive set here. Consider simplifying
      # this after confirming which keys can be set in practice.

      healthy_threshold   = health_check.value.healthy_threshold
      interval            = health_check.value.interval
      target              = health_check.value.target
      timeout             = health_check.value.timeout
      unhealthy_threshold = health_check.value.unhealthy_threshold
    }
  }

  # Variables to enabled SSL on your ELB
  #ssl_certificate_id = "${data.aws_acm_certificate.cert.arn}"
  cross_zone_load_balancing = var.cross_zone_load_balancing

  connection_draining         = var.connection_draining
  connection_draining_timeout = var.connection_draining_timeout
  internal                    = var.internal
}

resource "aws_security_group" "web" {
  name_prefix = "${local.app_name}-web"
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

