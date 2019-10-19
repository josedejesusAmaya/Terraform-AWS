// Configure AWS Cloud provider
provider "aws" {
  region = "us-east-1"
}

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
  name = "sample-app-elb-dev"
  subnets         = data.aws_subnet_ids.vpc_subnets.ids
  security_groups = [aws_security_group.web.id]
  tags = merge(
    var.tags,
    {
      "Name" = format("%s", "sample-app-elb-dev")
    },
  )
  listener {
    instance_port     = "80"
    instance_protocol = "HTTP"
    lb_port           = "80"
    lb_protocol       = "HTTP"
  }
  health_check {
    target              = "HTTP:80/"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
  }
  cross_zone_load_balancing   = true
  connection_draining         = true
  connection_draining_timeout = 100
  internal                    = false
}

#===========================================
#  Route 53 Record
#===========================================
resource "aws_route53_zone" "tf-workshop" {
  name = var.domain
}

resource "aws_route53_record" "dns_web" {
  zone_id = aws_route53_zone.tf-workshop.zone_id
  name    = "my-lb-example.terraform-workshop.com.mx"
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
  name_prefix                 = "sample-app-dev-lc-latest-"
  image_id                    = "ami-0b69ea66ff7391e80"
  instance_type               = "t2.micro"
  security_groups             = [aws_security_group.web.id]
  user_data                   = data.template_file.deploy_sh.rendered
  associate_public_ip_address = false
  # spot_price                  = "0.02"

  lifecycle {
    create_before_destroy = true
  }
}

#===========================================
#  Auto scaling Group
#===========================================
resource "aws_autoscaling_group" "asg" {
  name = aws_launch_configuration.lc.name
  launch_configuration = aws_launch_configuration.lc.name
  load_balancers            = [aws_elb.elb.id]
  health_check_type         = "ELB"
  health_check_grace_period = 60
  default_cooldown          = 60
  min_size                  = 1
  max_size                  = 1
  wait_for_elb_capacity     = 1
  desired_capacity          = 1
  vpc_zone_identifier = data.aws_subnet_ids.vpc_subnets.ids

  //TAGS propagated to each EC2 instance
  tags = [
    {
      "key"                 = "Name"
      "value"               = "sample-app-dev-ec2-latest"
      "propagate_at_launch" = true
    },
  ]

  lifecycle {
    create_before_destroy = true
  }
}

#===========================================
#  Output Load Balancer DNS
#===========================================
output "elb_dns" {
  value = aws_elb.elb.dns_name
}
