resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

resource "aws_security_group" "web" {
  name        = "web"
  description = "Allow web traffic"
  vpc_id      = "${aws_default_vpc.default.id}"

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

  tags = {
    Terraform  = true
    Service    = "web"
    Customer   = "Stark Industries"
    Owner      = "Wizeline"
    Maintainer = "devops@wizeline.com"
  }
}

resource "aws_instance" "web" {
  ami           = "${data.aws_ami.amazon_linux.id}"
  instance_type = "t2.micro"

  provisioner "local-exec" {
    command = "bash -c 'MAX=10; C=0; until curl -s -o /dev/null ${aws_instance.web.public_dns}; do [ $C -eq $MAX ] && { exit 1; } || sleep 10; ((C++)); done;' || false"
  }

  user_data = <<-EOF
    #!/bin/bash
    #Update installed pacakges
    yum update -y

    #Install docker
    yum install -y docker

    #Start Docker
    sudo service docker start

    #Add ec2-user to the docker group
    #All commands here are executed as super admin
    #but still, let's add the ec2-user to the docker group
    usermod -a -G docker ec2-user 

    #Run the nginx 
    docker run -d -p 80:80 nginx
    
  EOF

  vpc_security_group_ids = ["${aws_security_group.web.id}"]

  tags = {
    Terraform  = true
    Service    = "web"
    Customer   = "Stark Industries"
    Owner      = "Wizeline"
    Maintainer = "devops@wizeline.com"
  }
}
