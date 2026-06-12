#!/bin/bash

set -e

DOCKER_IMAGE_NAME="llama-factory-local"
DOCKER_IMAGE_TAG="v0.9.5"

WORKSPACE_DIR="${PWD}/workspace"
LLAMA_FACTORY_DIR="${PWD}/llama-factory"
mkdir -p ${WORKSPACE_DIR}

echo "=== Running Llama-Factory container ==="
echo "Workspace: ${WORKSPACE_DIR}"
echo "Jupyter Lab: http://localhost:8000"
echo "Gradio WebUI: http://localhost:7860"

if [ -n "${CUSTOM_ARGS}" ]; then
    echo "Custom Args: ${CUSTOM_ARGS}"
fi

docker run -it --rm \
    --gpus all \
    --name llama-factory-container \
    -p 8000:8000 \
    -p 7860:7860 \
    -v ${WORKSPACE_DIR}:/workspace \
    -v ${LLAMA_FACTORY_DIR}:/workspace/llama-factory \
    -e REPO_ID="" \
    -e REVISION="" \
    -e CONTEXT_PATH="/" \
    ${CUSTOM_ARGS:+ -e CUSTOM_ARGS="$CUSTOM_ARGS"} \
    ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}

echo "=== Container stopped ==="