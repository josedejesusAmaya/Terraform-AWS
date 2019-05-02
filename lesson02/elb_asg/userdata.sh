#!/bin/bash
## hostname setup
hostnamectl set-hostname ${HOSTNAME}
#Update installed pacakges
 #Install docker
yum install -y docker
 #Start Docker
sudo service docker start
 #Add ec2-user to the docker group
#All commands here are executed as super admin
#but still, let's add the ec2-user to the docker group
usermod -a -G docker ec2-user 
 #Run the nginx 
docker run -d -p 80:80 --restart=always nginx:${docker_tag}