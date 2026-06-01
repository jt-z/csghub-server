#!/bin/bash

MODEL_PATH="${MODEL_PATH:-/workspace/output}"
TEMPLATE="${TEMPLATE:-qwen2}"

CUDA_VISIBLE_DEVICES=0 llamafactory-cli webchat \
    --model_name_or_path ${MODEL_PATH} \
    --template ${TEMPLATE} \
    --finetuning_type lora