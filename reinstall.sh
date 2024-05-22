#!/bin/bash

# Stop and remove the existing container
docker stop titan1
docker rm titan1

# Remove the volume directory
rm -rf ~/.titanedge

# Update package lists
apt update -y

# Install Docker
apt-get install docker.io -y

# Install required packages
apt-get install ca-certificates curl gnupg lsb-release -y

# Pull Docker image
docker pull nezha123/titan-edge:latest

# Create path
mkdir ~/.titanedge

# Run Docker container with host network
docker run --network=host -d -v ~/.titanedge:/root/.titanedge --name titan1 nezha123/titan-edge:latest

# Wait for the container to initialize
sleep 10

# Bind container to API
docker exec titan1 titan-edge bind --hash=5D6040E3-AF64-47F1-9B42-D0FA4436C240 https://api-test1.container1.titannet.io/api/v2/device/binding

# Set storage size for container
docker exec titan1 titan-edge config set --storage-size 58GB

# Wait for the configuration to take effect
sleep 5

# Change directory to the volume path
cd ~/.titanedge

# Update the LocatorURL in the config file
sed -i 's#LocatorURL = "https://test-locator.titannet.io:5000/rpc/v0"#LocatorURL = "https://us-locator.titannet.io:5000/rpc/v0"#' config.toml

# Wait for the changes to be saved
sleep 1

# Ensure the container always restarts
docker update --restart=always titan1

# Restart the container to apply changes
sleep 2
docker restart titan1
