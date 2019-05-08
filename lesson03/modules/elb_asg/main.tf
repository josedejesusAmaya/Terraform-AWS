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
  appversion = "${var.metadata["appversion"]}"
}

#--------------------------------------------------------------
# Launch configuration
#--------------------------------------------------------------
resource "aws_launch_configuration" "lc" {
  lifecycle {
    create_before_destroy = true
  }

  name_prefix     = "${local.app_name}-lc-${local.appversion}-"
  image_id        = "${data.aws_ami.amazon_linux.id}"
  instance_type   = "${var.instance_type}"
  security_groups = ["${aws_security_group.web.id}"]

  //iam_instance_profile        = "${var.iam_role}" //Optional ami role assigned to the EC2 instance
  user_data                   = "${data.template_file.deploy_sh.rendered}"
  key_name                    = "${var.key_name}"
  associate_public_ip_address = "${var.associate_public_ip_address}"
}

#===========================================
#  Auto scaling Group
#===========================================
resource "aws_autoscaling_group" "asg" {
  name_prefix          = "${local.app_name}-asg-${local.appversion}-"
  launch_configuration = "${aws_launch_configuration.lc.name}"

  # workarround for issue: https://github.com/hashicorp/terraform/issues/15978
  # if vpc_zone_identifier is used, do not use availability_zones
  # availability_zones        = ["${var.aws_availability_zones}"]
  load_balancers = ["${aws_elb.elb.id}"]

  health_check_type         = "${var.health_check_type}"
  health_check_grace_period = "${var.health_check_grace_period}"
  default_cooldown          = "${var.default_cooldown}"

  min_size = "${var.min_size}"
  max_size = "${var.max_size}"

  desired_capacity = "${var.desired_capacity}"

  vpc_zone_identifier = ["${slice(data.aws_subnet_ids.vpc_subnets.ids, 0, 2)}"]

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
  tags = "${list(
    map("key", "Name",          "value", "${local.app_name}-ec2-${local.appversion}",         "propagate_at_launch", true)
  )}"
  lifecycle {
    create_before_destroy = true
  }
}

#===========================================
#  Elastic Load Balancer
#===========================================
resource "aws_elb" "elb" {
  name            = "${local.app_name}-elb"
  subnets         = ["${slice(data.aws_subnet_ids.vpc_subnets.ids, 0, 2)}"]
  security_groups = ["${aws_security_group.web.id}"]
  tags            = "${merge(var.tags, map("Name", format("%s", "${local.app_name}-elb")))}"

  listener     = ["${var.elb_listener}"]
  health_check = ["${var.elb_health_check}"]

  # Variables to enabled SSL on your ELB
  #ssl_certificate_id = "${data.aws_acm_certificate.cert.arn}"
  cross_zone_load_balancing = "${var.cross_zone_load_balancing}"

  connection_draining         = "${var.connection_draining}"
  connection_draining_timeout = "${var.connection_draining_timeout}"
  internal                    = "${var.internal}"
}

resource "aws_security_group" "web" {
  name_prefix = "${local.app_name}-web"
  description = "Allow web traffic"
  vpc_id      = "${aws_default_vpc.default.id}"

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
