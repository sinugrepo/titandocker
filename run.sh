#!/bin/bash

# Update package lists
apt update -y

# Install Docker
apt-get install docker.io -y

# Install required packages
apt-get install ca-certificates curl gnupg lsb-release -y

# Pull Docker image
docker pull nezha123/titan-edge:latest

#create path
mkdir ~/.titanedge

# Run Docker containers nat
docker run --network=host -d -v ~/.titanedge:/root/.titanedge --name titan1 nezha123/titan-edge:latest

sleep 5

# Bind containers to API
docker exec titan1 titan-edge bind --hash=5D6040E3-AF64-47F1-9B42-D0FA4436C240 https://api-test1.container1.titannet.io/api/v2/device/binding

# Set storage size for containers
docker exec titan1 titan-edge config set --storage-size 59GB

#restart
docker restart titan1
