# Llama-Factory Local Deployment

This directory contains a local standalone version of Llama-Factory for fine-tuning LLMs.

## Prerequisites

- Docker with NVIDIA GPU support (nvidia-docker)
- NVIDIA GPU with CUDA support

## Quick Start

### 1. Build the Docker image

```bash
chmod +x build.sh run.sh
./build.sh
```

### 2. Run the container

```bash
./run.sh
```

### 3. Access the services

- **Jupyter Lab**: http://localhost:8000
- **Gradio WebUI**: http://localhost:7860

---

## Training Methods

### Method 1: WebUI (Gradio Interface)

访问 http://localhost:7860 进入 Gradio WebUI 界面：

1. **选择模型**: 在顶部选择或输入模型名称
2. **配置训练**: 切换到 Train 标签页
3. **设置参数**: 配置数据集、epoch、learning rate 等
4. **启动训练**: 点击 Start Training 按钮

**优势**: 图形化操作，适合快速实验
**劣势**: 不适合大规模训练，参数配置有限

---

### Method 2: Command Line Training

进入容器后，使用 `llamafactory-cli train` 命令行训练：

```bash
# 基本 SFT 训练
CUDA_VISIBLE_DEVICES=0 llamafactory-cli train \
    --stage sft \
    --model_name_or_path Qwen/Qwen2-0.5B \
    --dataset phone_en \
    --dataset_dir /workspace/data \
    --template qwen2 \
    --finetuning_type lora \
    --output_dir /workspace/output \
    --num_train_epochs 3 \
    --per_device_train_batch_size 1
```

**优势**: 完整参数控制，适合生产环境
**劣势**: 需要熟悉命令行参数

---

### Method 3: YAML Configuration File

创建 YAML 配置文件进行训练：

```bash
# 使用预定义的配置示例
./llama-factory/train_with_yaml.sh

# 或手动指定配置文件
CUDA_VISIBLE_DEVICES=0 llamafactory-cli train ./llama-factory/example_sft.yaml
```

**优势**: 配置清晰，易于版本控制和复用
**劣势**: 需要创建配置文件

---

## Training Scripts

本目录提供了三个训练脚本：

### 1. train_sft.sh (Minimal)

基本 SFT 训练脚本，仅包含核心参数：

```bash
# 使用默认参数
./llama-factory/train_sft.sh

# 自定义参数
MODEL_NAME=Qwen/Qwen2-0.5B DATASET=phone_en TRAIN_EPOCHS=3 \
    ./llama-factory/train_sft.sh
```

### 2. train_sft_full.sh (Full Parameters)

完整参数版本，包含所有常用训练参数：

```bash
# 使用完整参数训练
MODEL_NAME=Qwen/Qwen2-0.5B \
DATASET=phone_en \
TRAIN_EPOCHS=3 \
LEARNING_RATE=1.0e-5 \
OUTPUT_DIR=/workspace/output \
./llama-factory/train_sft_full.sh
```

### 3. train_with_yaml.sh

使用 YAML 配置文件进行训练：

```bash
CONFIG_FILE=/etc/csghub/example_sft.yaml ./llama-factory/train_with_yaml.sh
```

---

## Key Training Parameters

### Model Parameters

| Parameter | Description | Example |
|-----------|-------------|---------|
| `model_name_or_path` | 模型名称或本地路径 | `Qwen/Qwen2-0.5B` |
| `template` | 模型模板 | `qwen2`, `llama3`, `chatglm` |
| `finetuning_type` | 微调类型 | `lora`, `full`, `adalora` |

### Dataset Parameters

| Parameter | Description | Example |
|-----------|-------------|---------|
| `dataset` | 数据集名称 | `phone_en`, `alpaca_en` |
| `dataset_dir` | 数据集目录 | `/workspace/data` |
| `cutoff_len` | 最大序列长度 | `512`, `1024` |

### LoRA Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `lora_rank` | LoRA rank | `8` |
| `lora_alpha` | LoRA alpha | `16` |
| `lora_dropout` | LoRA dropout | `0.05` |
| `lora_target` | LoRA 目标模块 | `all`, `q_proj,v_proj` |

### Training Hyperparameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `num_train_epochs` | 训练轮数 | `3` |
| `per_device_train_batch_size` | 每设备 batch 大小 | `1` |
| `gradient_accumulation_steps` | 梯度累积步数 | `16` |
| `learning_rate` | 学习率 | `1.0e-5` |
| `weight_decay` | 权重衰减 | `0.01` |
| `lr_scheduler_type` | 学习率调度器 | `cosine` |
| `warmup_ratio` | 预热比例 | `0.1` |

### Output and Logging

| Parameter | Description | Default |
|-----------|-------------|---------|
| `output_dir` | 输出目录 | `/workspace/output` |
| `logging_steps` | 日志记录步数 | `10` |
| `save_steps` | 保存 checkpoint 步数 | `100` |
| `save_total_limit` | 最多保存 checkpoint 数 | `2` |

---

## Chat with Fine-tuned Model

训练完成后，使用 `chat.sh` 与模型对话：

```bash
# 默认使用 /workspace/output 中的模型
./llama-factory/chat.sh

# 自定义模型路径
MODEL_PATH=/workspace/output \
TEMPLATE=qwen2 \
./llama-factory/chat.sh
```

---

## Customization

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `REPO_ID` | Model repository ID | `""` |
| `REVISION` | Model revision/branch | `""` |
| `CONTEXT_PATH` | Base path for services | `"/"` |

### Example with custom model

```bash
docker run -it --rm \
    --gpus all \
    --name llama-factory-container \
    -p 8000:8000 \
    -p 7860:7860 \
    -v ${PWD}/workspace:/workspace \
    -e REPO_ID="Qwen/Qwen2-0.5B" \
    llama-factory-local:v0.9.5
```

---

## Directory Structure

```
self/docker/
├── Dockerfile              # Main Dockerfile
├── build.sh              # Build script
├── run.sh                # Run script
├── README.md             # This file
└── llama-factory/        # Configuration files
    ├── supervisord.conf          # Supervisor configuration
    ├── jupyter_notebook_config.py # Jupyter config
    ├── start.sh                  # Llama-Factory startup script
    ├── start_jupyter.sh          # Jupyter startup script
    ├── mem_monitor.sh            # Memory monitor script
    ├── get_model_name.py         # Model name helper script
    ├── train_sft.sh             # Basic SFT training script
    ├── train_sft_full.sh        # Full SFT training script
    ├── train_with_yaml.sh       # YAML config training script
    ├── chat.sh                  # Chat with fine-tuned model
    └── example_sft.yaml         # Example YAML config
```

---

## Dataset Preparation

将训练数据放入 `/workspace/data` 目录，LlamaFactory 支持多种数据集格式：

### Alpaca 格式

```json
[
  {
    "instruction": "用户指令",
    "input": "输入内容",
    "output": "期望输出"
  }
]
```

### ShareGPT 格式

```json
[
  {
    "conversations": [
      {"from": "human", "content": "用户消息"},
      {"from": "gpt", "content": "助手回复"}
    ]
  }
]
```

---

## Notes

1. The workspace directory (`./workspace`) is persisted across container runs
2. All data, examples, and trained models are stored in the workspace
3. Make sure you have enough GPU memory for model loading and training
4. First run may take time to initialize data directories
5. Use `docker exec -it llama-factory-container bash` to enter running container