#!/bin/bash

CONFIG_FILE="${CONFIG_FILE:-/etc/csghub/example_sft.yaml}"

echo "=== LlamaFactory SFT Training with YAML Config ==="
echo "Config: ${CONFIG_FILE}"

CUDA_VISIBLE_DEVICES=0 llamafactory-cli train ${CONFIG_FILE}