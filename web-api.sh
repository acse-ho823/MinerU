#!/bin/bash

# Define image and container names
IMAGE_NAME="mineru:web_api"
CONTAINER_NAME="mineru_server"
DOCKER_DIR="/home/ubuntu/MinerU/projects/web_api"

# Step 0: Change to the directory containing the Dockerfile
cd $DOCKER_DIR
echo "Current directory: $(pwd)"

# Step 1: Build the Docker image
echo "Building the Docker image..."
docker build -t $IMAGE_NAME .

# Step 2: Check if a container with the same name already exists and stop/remove it
if [ "$(docker ps -aq -f name=$CONTAINER_NAME)" ]; then
    echo "Stopping and removing the existing container..."
    docker stop $CONTAINER_NAME
    docker rm $CONTAINER_NAME
fi

# Step 3: Run the Docker container
echo "Starting the Docker container..."
docker run -itd \
    --name=$CONTAINER_NAME \
    --gpus=all \
    -p 8888:8000 \
    $IMAGE_NAME

echo "Docker container is running!"
echo "Access the application at http://localhost:8888"
