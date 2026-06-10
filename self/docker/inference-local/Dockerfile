
# 基于官方 vLLM OpenAI 镜像构建，支持 OpenAI API 兼容接口
FROM vllm/vllm-openai:v0.20.1

# 配置国内 pip 镜像源，加速依赖安装
RUN pip config set global.index-url https://mirrors.aliyun.com/pypi/simple

# 安装必要的 Python 依赖
RUN pip install --no-cache-dir csghub-sdk==0.7.3 ray supervisor

# 配置国内 Ubuntu 镜像源，加速系统依赖安装
RUN sed -i 's|http://archive.ubuntu.com/ubuntu|http://mirrors.aliyun.com/ubuntu|g' /etc/apt/sources.list && \
    sed -i 's|http://security.ubuntu.com/ubuntu|http://mirrors.aliyun.com/ubuntu|g' /etc/apt/sources.list && \
    sed -i 's|http://ports.ubuntu.com/ubuntu-ports|http://mirrors.aliyun.com/ubuntu-ports|g' /etc/apt/sources.list && \
    apt-get update && apt-get install -y supervisor && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# 创建日志目录
RUN mkdir -p /var/log/supervisord

# 复制 supervisord 配置文件
COPY ./supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# 复制 vLLM 服务脚本
COPY ./vllm/ /etc/csghub/

# 赋予脚本执行权限
RUN chmod +x /etc/csghub/*.sh && \
    chmod +x /vllm-workspace/examples/online_serving/*.sh

# 设置工作目录
WORKDIR /workspace/

# 配置环境变量
ENV HUGGINGFACE_HUB_CACHE=/workspace/ \
    HF_HUB_ENABLE_HF_TRANSFER=0

# 暴露服务端口
EXPOSE 8000

# 启动命令
ENTRYPOINT ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
