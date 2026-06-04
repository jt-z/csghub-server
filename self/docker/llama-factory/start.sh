#!/bin/bash

if [ "x${REPO_ID}" != "x" ]; then
    if [ -f "/app/src/llamafactory/extras/constants.py" ]; then
        MODEL_NAME=$(python3 /etc/csghub/get_model_name.py "${REPO_ID}" 2>/dev/null)
    fi
    if [ -z "${MODEL_NAME}" ]; then
        MODEL_NAME=$(echo "$REPO_ID" | cut -d'/' -f2)
    fi

    sed -i "s#model_name = gr.Dropdown(choices=available_models, value=None, scale=2)#model_name = gr.Dropdown(choices=available_models,value=\"${MODEL_NAME}\", interactive=False, scale=2)#" /app/src/llamafactory/webui/components/top.py
    sed -i "s#model_path = gr.Textbox(scale=2)#model_path = gr.Textbox(value=\"${REPO_ID}\",scale=2)#" /app/src/llamafactory/webui/components/top.py
    sed -i "s#Hugging Face hub#Local Hub#g" /app/src/llamafactory/webui/locales.py
    sed -i "s#Hugging Face Hub#Local Hub#g" /app/src/llamafactory/webui/locales.py
    sed -i "s#HF Hub#Local Hub#g" /app/src/llamafactory/webui/locales.py
fi

if [ ! -f "/workspace/.csghub_init" ]; then
    if [ ! -d "/workspace/data" ]; then
        cp -rf /app/data /workspace/data
    fi
    if [ ! -d "/workspace/examples" ]; then
        cp -rf /app/examples /workspace/examples
    fi
    if [ "x${REVISION}" != "x" ]; then
        sed -i "s/model_args.model_revision/\"$REVISION\"/g" /app/src/llamafactory/model/loader.py
    fi
    touch /workspace/.csghub_init
fi

sed -i "s|and repo_type != constants.REPO_TYPE_MODEL||g" /usr/local/lib/python3.11/dist-packages/huggingface_hub/hf_api.py

# 本地测试，取消NGINX反向代理的路径前缀 "/" “proxy/” ，之后就可以了 
export GRADIO_ROOT_PATH=""
ascend_env=/usr/local/Ascend/ascend-toolkit/set_env.sh
if [ -f "$ascend_env" ]; then
    source $ascend_env
    ASCEND_VISIBLE_DEVICES=0 llamafactory-cli webui
else
    CUDA_VISIBLE_DEVICES=0 llamafactory-cli webui --server-name 0.0.0.0 --server-port 7860
fi