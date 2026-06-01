#!/bin/bash

set -e

DOCKER_IMAGE_NAME="llama-factory-local"
DOCKER_IMAGE_TAG="v0.9.5"

echo "=== Building Docker image: ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} ==="

docker build -t ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} \
    -f Dockerfile \
    .

echo "=== Build completed successfully ==="
echo "Image: ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}"