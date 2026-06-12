#!/bin/bash

MODEL_NAME="${MODEL_NAME:-Qwen/Qwen3.5-0.8B}"
DATASET="${DATASET:-identity,alpaca_en_demo}"
OUTPUT_DIR="${OUTPUT_DIR:-/workspace/saves/qwen3.5-0.8b/lora/sft}"
TRAIN_EPOCHS="${TRAIN_EPOCHS:-3.0}"
LEARNING_RATE="${LEARNING_RATE:-1.0e-4}"

echo "=== LlamaFactory SFT Training - Qwen3.5-0.8B ==="
echo "Model: ${MODEL_NAME}"
echo "Dataset: ${DATASET}"
echo "Output Dir: ${OUTPUT_DIR}"
echo "Epochs: ${TRAIN_EPOCHS}"
echo "Learning Rate: ${LEARNING_RATE}"

mkdir -p ${OUTPUT_DIR}

CUDA_VISIBLE_DEVICES=0 llamafactory-cli train \
    --stage sft \
    --do_train true \
    --model_name_or_path ${MODEL_NAME} \
    --trust_remote_code true \
    --dataset ${DATASET} \
    --dataset_dir /workspace/data \
    --template qwen3_nothink \
    --finetuning_type lora \
    --lora_rank 8 \
    --lora_target all \
    --output_dir ${OUTPUT_DIR} \
    --overwrite_output_dir true \
    --save_only_model false \
    --logging_steps 10 \
    --save_steps 500 \
    --plot_loss true \
    --report_to none \
    --per_device_train_batch_size 1 \
    --gradient_accumulation_steps 8 \
    --learning_rate ${LEARNING_RATE} \
    --num_train_epochs ${TRAIN_EPOCHS} \
    --lr_scheduler_type cosine \
    --warmup_ratio 0.1 \
    --bf16 true \
    --ddp_timeout 180000000 \
    --cutoff_len 2048 \
    --max_samples 1000 \
    --preprocessing_num_workers 16 \
    --dataloader_num_workers 4