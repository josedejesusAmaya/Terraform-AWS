#!/bin/bash
#
# Installs Docker, and runs a container

# Updates packages
yum update -y

# Installs Docker
yum install -y docker

# Starts Docker service
service docker start

# Allows ec2-user to execute Docker
usermod -a -G docker ec2-user

# Runs a Docker container with image ${docker_image}:${docker_tag}
# - runs container in the background
# - exposes container's port 80 in the host's port 80
# - restarts container if it stops
docker run -d -p 80:80 --restart=always ${docker_image}:${docker_tag}
