#!/bin/bash

# Update package lists
apt update -y

sleep 1

# Install Docker
apt-get install docker.io -y

# Install required packages
apt-get install ca-certificates curl gnupg lsb-release -y

# Pull Docker image
docker pull nezha123/titan-edge:latest

# Loop to create 18 containers
for i in $(seq 1 18); do
  # Create path for storing configurations
  mkdir -p ~/.titanedge$i

  # Run Docker container with host network
  docker run --network=host -d -v ~/.titanedge$i:/root/.titanedge --name titan$i nezha123/titan-edge:latest

  sleep 10

  # Install Warp inside the container
  docker exec titan$i bash -c "
    apt update -y && 
    apt install -y curl &&
    curl https://pkg.cloudflareclient.com/pubkey.gpg | apt-key add - &&
    echo 'deb http://pkg.cloudflareclient.com/ buster main' | tee /etc/apt/sources.list.d/cloudflare-client.list &&
    apt update -y &&
    apt install -y cloudflare-warp &&
    warp-cli register &&
    warp-cli connect &&
    warp-cli status
  "

  # Bind container to API
  docker exec titan$i titan-edge bind --hash=D48160C8-5C42-4F78-B689-3FAE79A307FB https://api-test1.container1.titannet.io/api/v2/device/binding

  # Set storage size for the container
  docker exec titan$i titan-edge config set --storage-size 50GB

  sleep 5

  # Update container to always restart
  docker update --restart=always titan$i

  sleep 2

  # Restart the container to apply changes
  docker restart titan$i
done
