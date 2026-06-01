#!/bin/bash

MODEL_NAME="${MODEL_NAME:-Qwen/Qwen2-0.5B}"
DATASET="${DATASET:-phone_en}"
TRAIN_EPOCHS="${TRAIN_EPOCHS:-3}"
LEARNING_RATE="${LEARNING_RATE:-1.0e-5}"
OUTPUT_DIR="${OUTPUT_DIR:-/workspace/output}"

echo "=== LlamaFactory SFT Training (Full Parameters) ==="
echo "Model: ${MODEL_NAME}"
echo "Dataset: ${DATASET}"
echo "Epochs: ${TRAIN_EPOCHS}"
echo "Learning Rate: ${LEARNING_RATE}"
echo "Output Dir: ${OUTPUT_DIR}"

mkdir -p ${OUTPUT_DIR}

CUDA_VISIBLE_DEVICES=0 llamafactory-cli train \
    --stage sft \
    --do_train true \
    --model_name_or_path ${MODEL_NAME} \
    --dataset ${DATASET} \
    --dataset_dir /workspace/data \
    --template qwen2 \
    --finetuning_type lora \
    --lora_target all \
    --output_dir ${OUTPUT_DIR} \
    --overwrite_cache \
    --overwrite_output_dir \
    --warmup_ratio 0.1 \
    --bf16 true \
    --num_train_epochs ${TRAIN_EPOCHS} \
    --per_device_train_batch_size 1 \
    --gradient_accumulation_steps 16 \
    --learning_rate ${LEARNING_RATE} \
    --weight_decay 0.01 \
    --lora_rank 8 \
    --lora_alpha 16 \
    --lora_dropout 0.05 \
    --lr_scheduler_type cosine \
    --logging_steps 10 \
    --save_steps 100 \
    --save_total_limit 2 \
    --cutoff_len 512 \
    --max_grad_norm 1.0 \
    --gradient_checkpointing true