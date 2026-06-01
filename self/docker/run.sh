#!/bin/bash

set -e

DOCKER_IMAGE_NAME="llama-factory-local"
DOCKER_IMAGE_TAG="v0.9.5"

WORKSPACE_DIR="${PWD}/workspace"
mkdir -p ${WORKSPACE_DIR}

echo "=== Running Llama-Factory container ==="
echo "Workspace: ${WORKSPACE_DIR}"
echo "Jupyter Lab: http://localhost:8000"
echo "Gradio WebUI: http://localhost:7860"

docker run -it --rm \
    --gpus all \
    --name llama-factory-container \
    -p 8000:8000 \
    -p 7860:7860 \
    -v ${WORKSPACE_DIR}:/workspace \
    -e REPO_ID="" \
    -e REVISION="" \
    -e CONTEXT_PATH="/" \
    ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}

echo "=== Container stopped ==="