# Configure AWS Cloud provider
provider "aws" {
  region = "us-east-2"
}

# Configure default vpc present in
# AWS account
resource "aws_default_vpc" "default" {
  tags = var.tags
}

# Creation of the security group (SG) that
# is going to be used for our instance
resource "aws_security_group" "web" {
  # Name to be assigned to the SG
  name        = "${data.aws_caller_identity.current.user_id}-web"
  # Description of the SG
  description = "Allow web traffic"
  # We're calling the `aws_default_vpc` default resource
  # This gets the id from the vpc imported above (line 8)
  vpc_id      = aws_default_vpc.default.id

  # Ingress rules for the SG
  # Lines 32-37 allow TCP port 22 for all IPs (ssh)
  # Lines 40-45 allow TCP port 80 for all IPs (http)
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

  # Egress rules for the SG
  # Lines 49-54 allow egress traffic for all ports (0)
  # for all protocols (-1) to all IPs
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Adds tags defined in `variables.tf` to this resource
  tags = var.tags
}

# Creation of the EC2 instance that will serve as
# web server.
resource "aws_instance" "web" {
  # AMI image computed by Terraform, see the
  # `data.tf` file to check how it is computed.
  ami           = data.aws_ami.amazon_linux.id
  # Instance type to use
  instance_type = "m4.large"
  # SSH key name that is going to be used to
  # access our instance.
  # Please create this resource from the AWS console
  # first
  key_name      = var.instance_key

  # This step will execute a command on our local machine,
  # it will wait until the EC2 instance is ready to work.
  provisioner "local-exec" {
    command = "bash -c 'MAX=10; C=0; until curl -s -o /dev/null ${aws_instance.web.public_dns}; do [ $C -eq $MAX ] && { exit 1; } || sleep 10; ((C++)); done;' || false"
  }

  # Command used to set up our instance, will install docker and
  # run an nginx container. This command is found in `lesson01/templates`
  # and is rendered by a terraform provider in the `data.tf` file
  user_data = data.template_file.user_data.rendered
  # List that contains the SGs IDs to apply to the instance
  vpc_security_group_ids = [aws_security_group.web.id]
  # Tags to identify the instance, this will help us identify the
  # instance
  tags = merge(
    var.tags,
    {
      "Name" = format("%s-%s", data.aws_caller_identity.current.user_id, "ec2")
    },
  )
}

# Uncomment this if you have a hosted zone in your AWS account
# Creation of the Route53 DNS record to point to the instance IP
# resource "aws_route53_record" "dns_web" {
#   # AWS Hosted Zone present in the account, computed by Terraform
#   zone_id = data.aws_route53_zone.current.zone_id
#   # DNS record, uses the AWS identity of the user and the domain
#   # provided in `variables.tf`
#   name    = "${data.aws_caller_identity.current.user_id}.${var.domain}"
#   # Record type (https://simpledns.com/help/dns-record-types)
#   type    = "A"
#   # Time to live
#   ttl     = 300
#   # Instance IP, the record will point to this IP address
#   records = [aws_instance.web.public_ip]
# }
