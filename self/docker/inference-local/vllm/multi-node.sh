#!/bin/bash

export PYTHONPATH="$(pwd):$PYTHONPATH"

# 执行入口脚本（如果存在）
if [ -f "/etc/csghub/entry.py" ]; then
    python3 /etc/csghub/entry.py
fi

GPU_MEMORY_UTILIZATION=0.9
ENGINE_ARGS="$ENGINE_ARGS --trust-remote-code --model $REPO_ID --port 8000 --pipeline-parallel-size $LWS_GROUP_SIZE --enforce-eager"

# 设置 tensor-parallel-size
if [[ ! $ENGINE_ARGS == *"--tensor-parallel-size"* ]]; then
    ENGINE_ARGS="$ENGINE_ARGS --tensor-parallel-size $GPU_NUM"
fi

# 设置 gpu-memory-utilization
if [[ ! $ENGINE_ARGS == *"--gpu-memory-utilization"* ]]; then
    ENGINE_ARGS="$ENGINE_ARGS --gpu-memory-utilization $GPU_MEMORY_UTILIZATION"
fi

# 设置 max-model-len
if [[ ! $ENGINE_ARGS == *"--max-model-len"* ]]; then
    ENGINE_ARGS="$ENGINE_ARGS --max-model-len 9016"
fi

# 配置 chat template
tokenizer_config="/workspace/$REPO_ID/tokenizer_config.json"
if [ -f "$tokenizer_config" ] && ! grep -q "chat_template" "$tokenizer_config"; then
    if [ -f "/workspace/$REPO_ID/chat_template.jinja" ]; then
        ENGINE_ARGS="$ENGINE_ARGS --chat_template /workspace/$REPO_ID/chat_template.jinja"
    elif [ -f "/etc/csghub/chat_template.jinja" ]; then
        ENGINE_ARGS="$ENGINE_ARGS --chat_template /etc/csghub/chat_template.jinja"
    fi
fi

# 启用 enforce-eager（如果需要）
if [ "${VLLM_ENFORCE_EAGER}" = "true" ] || [ "${VLLM_ENFORCE_EAGER}" = "1" ]; then
    ENGINE_ARGS="$ENGINE_ARGS --enforce-eager"
    echo "Enabled --enforce-eager via env var."
fi

echo "ENGINE_ARGS: $ENGINE_ARGS"

# 根据角色启动服务
if [ "$LWS_WORKER_INDEX" == "0" ]; then
    # Leader 节点
    /vllm-workspace/examples/online_serving/multi-node-serving.sh leader --ray_cluster_size=$LWS_GROUP_SIZE
    python3 -m vllm.entrypoints.openai.api_server $ENGINE_ARGS
else
    # Worker 节点
    /vllm-workspace/examples/online_serving/multi-node-serving.sh worker --ray_address=$LWS_LEADER_ADDRESS
fi
