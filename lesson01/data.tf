data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name = "name"

    values = [
      "amzn-ami-hvm-*-x86_64-gp2",
    ]
  }

  filter {
    name = "owner-alias"

    values = [
      "amazon",
    ]
  }

  owners = ["amazon"]
}

data "template_file" "user_data" {
  template = "${file("${path.module}/templates/user_data.sh.tpl")}"

  vars = {
    docker_image = "${var.app_name}"
    docker_tag   = "${var.app_version}"
  }
}

data "aws_caller_identity" "current" {}

data "aws_route53_zone" "current" {
  name = "${var.domain}"
}
