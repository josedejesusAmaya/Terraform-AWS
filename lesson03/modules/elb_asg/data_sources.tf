//list of subnets
data "aws_subnet_ids" "vpc_subnets" {
  vpc_id = aws_default_vpc.default.id
}

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

data "template_file" "deploy_sh" {
  template = file("${path.module}/userdata.sh")

  vars = {
    docker_tag  = local.appversion
    ENVIRONMENT = var.env
    HOSTNAME    = "${local.app_name}-ec2-${local.appversion}"
  }
}

