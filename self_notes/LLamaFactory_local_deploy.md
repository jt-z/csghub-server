让我梳理当前的目录结构并验证脚本权限：


 
          
## 当前目录结构梳理

### 完整目录结构

```
/home/ksa/csghub-server/self/docker/
├── Dockerfile              # 主 Dockerfile (基于 NVIDIA CUDA 12.6.3)
├── build.sh               # 镜像构建脚本 (已添加执行权限)
├── run.sh                 # 容器启动脚本 (已添加执行权限)
├── README.md              # 详细使用说明文档
├── workspace/             # 工作目录（运行时挂载到容器）
│   ├── data/              # 数据集目录
│   ├── examples/          # 示例配置文件
│   └── ...
└── llama-factory/         # 配置文件目录
    ├── supervisord.conf          # Supervisor 进程管理配置
    ├── jupyter_notebook_config.py # Jupyter Lab 配置
    ├── start.sh                  # Llama-Factory 启动脚本 (已添加执行权限)
    ├── start_jupyter.sh          # Jupyter 启动脚本 (已添加执行权限)
    ├── mem_monitor.sh            # 内存监控脚本 (已添加执行权限)
    ├── get_model_name.py         # 模型名称解析脚本
    ├── train_sft.sh              # 基础 SFT 训练脚本 (已添加执行权限)
    ├── train_sft_full.sh         # 完整参数 SFT 训练脚本 (已添加执行权限)
    ├── train_with_yaml.sh        # YAML 配置训练脚本 (已添加执行权限)
    ├── chat.sh                   # 模型推理脚本 (已添加执行权限)
    └── example_sft.yaml          # 训练配置示例 YAML
```

### 文件权限状态

| 文件 | 权限 | 状态 |
|------|------|------|
| `build.sh` | -rwxrwxr-x | ✅ 可执行 |
| `run.sh` | -rwxrwxr-x | ✅ 可执行 |
| `llama-factory/start.sh` | -rwxrwxr-x | ✅ 可执行 |
| `llama-factory/start_jupyter.sh` | -rwxrwxr-x | ✅ 可执行 |
| `llama-factory/mem_monitor.sh` | -rwxrwxr-x | ✅ 可执行 |
| `llama-factory/train_sft.sh` | -rwxrwxr-x | ✅ 可执行 |
| `llama-factory/train_sft_full.sh` | -rwxrwxr-x | ✅ 可执行 |
| `llama-factory/train_with_yaml.sh` | -rwxrwxr-x | ✅ 可执行 |
| `llama-factory/chat.sh` | -rwxrwxr-x | ✅ 可执行 |

### 使用流程

**1. 构建镜像**
```bash
cd /home/ksa/csghub-server/self/docker
./build.sh
```

**2. 启动容器**
```bash
./run.sh
```

**3. 访问服务**
- Jupyter Lab: http://localhost:8000
- Gradio WebUI: http://localhost:7860

**4. 命令行训练（进入容器后）**
```bash
# 基础 SFT 训练
./llama-factory/train_sft.sh

# 完整参数训练
./llama-factory/train_sft_full.sh

# YAML 配置训练
./llama-factory/train_with_yaml.sh

# 与训练后的模型对话
./llama-factory/chat.sh
```

### 脚本配合关系

```
build.sh ──构建──→ Docker 镜像
     │
     ▼
run.sh ──启动──→ 容器 (端口映射: 8000, 7860)
     │
     ├──→ supervisord ──→ Jupyter Lab (8000)
     │
     ├──→ supervisord ──→ LlamaFactory WebUI (7860)
     │
     └──→ supervisord ──→ mem_monitor (后台)
     │
     ▼
命令行训练脚本:
     ├── train_sft.sh          (基础训练)
     ├── train_sft_full.sh     (完整参数)
     ├── train_with_yaml.sh    (YAML配置)
     └── chat.sh               (模型推理)
```

所有脚本已准备就绪，可以直接使用！