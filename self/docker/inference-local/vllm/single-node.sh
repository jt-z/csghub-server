#!/bin/bash

export PYTHONPATH="$(pwd):$PYTHONPATH"

# 执行入口脚本（如果存在）
if [ -f "/etc/csghub/entry.py" ]; then
    python3 /etc/csghub/entry.py
fi

# 设置默认 GPU 数量
if [ -z "$GPU_NUM" ]; then
    GPU_NUM=1
fi

# 计算最大 token 数（每 GPU 5120）
LimitedMaxToken=$(($GPU_NUM * 5120))
GPU_MEMORY_UTILIZATION=0.9

# 构建引擎参数
# 支持绝对路径和相对路径
if [[ "$REPO_ID" == /* ]]; then
    MODEL_PATH="$REPO_ID"
else
    MODEL_PATH="/workspace/$REPO_ID"
fi

ENGINE_ARGS="$ENGINE_ARGS --trust-remote-code --model $MODEL_PATH"

# 设置 tensor-parallel-size
if [[ ! $ENGINE_ARGS == *"--tensor-parallel-size"* ]]; then
    ENGINE_ARGS="$ENGINE_ARGS --tensor-parallel-size $GPU_NUM"
fi

# 设置 gpu-memory-utilization
if [[ ! $ENGINE_ARGS == *"--gpu-memory-utilization"* ]]; then
    ENGINE_ARGS="$ENGINE_ARGS --gpu-memory-utilization $GPU_MEMORY_UTILIZATION"
fi

# 从模型配置中读取 max_position_embeddings
configfile="$MODEL_PATH/config.json"
if [[ -f "$configfile" ]] && [[ ! $ENGINE_ARGS == *"--max-model-len"* ]]; then
    MAX_TOKENS=$(grep '"max_position_embeddings"' $configfile | cut -d":" -f2 | sed 's/[^0-9]*//g')
    if [ -z "$MAX_TOKENS" ]; then
        MAX_TOKENS=$LimitedMaxToken
    fi
    if [ ! -z "$MAX_TOKENS" ]; then
        if [ $MAX_TOKENS -gt $LimitedMaxToken ]; then
            MAX_TOKENS=$LimitedMaxToken       
        fi
        ENGINE_ARGS="$ENGINE_ARGS --max-model-len $MAX_TOKENS"
    fi
fi

# 配置 chat template
tokenizer_config="$MODEL_PATH/tokenizer_config.json"
if [ -f "$tokenizer_config" ] && ! grep -q "chat_template" "$tokenizer_config"; then
    if [ -f "$MODEL_PATH/chat_template.jinja" ]; then
        ENGINE_ARGS="$ENGINE_ARGS --chat_template $MODEL_PATH/chat_template.jinja"
    elif [ -f "/etc/csghub/chat_template.jinja" ]; then
        ENGINE_ARGS="$ENGINE_ARGS --chat_template /etc/csghub/chat_template.jinja"
    fi
fi

# 启用 enforce-eager（如果需要）
if [ "${VLLM_ENFORCE_EAGER}" = "true" ] || [ "${VLLM_ENFORCE_EAGER}" = "1" ]; then
    ENGINE_ARGS="$ENGINE_ARGS --enforce-eager"
    echo "Enabled --enforce-eager via env var."
fi

# 设置日志级别，避免敏感信息泄露
# 默认使用 WARNING 级别，生产环境可设置为 ERROR
VLLM_LOG_LEVEL="${VLLM_LOG_LEVEL:-WARNING}"
export VLLM_LOG_LEVEL

# 启动 vLLM OpenAI API 服务（仅输出非敏感信息）
echo "Starting vLLM service with model: $MODEL_PATH (log level: $VLLM_LOG_LEVEL)"

# 使用 Python 包装器来过滤敏感日志
python3 << 'PYTHON_SCRIPT'
import os
import sys
import logging
from vllm.entrypoints.openai.api_server import main

# 设置日志级别，过滤敏感信息
logging.basicConfig(
    level=os.environ.get("VLLM_LOG_LEVEL", "WARNING"),
    format="%(asctime)s %(levelname)s %(name)s: %(message)s"
)

# 禁用详细的请求/响应日志
os.environ["VLLM_LOG_FORMAT"] = "%(levelname)s %(name)s: %(message)s"

if __name__ == "__main__":
    main()
PYTHON_SCRIPT "$@"
