#!/bin/bash
# 服务入口脚本，根据环境变量判断运行模式
if [ -z "$LWS_WORKER_INDEX" ]; then
    bash /etc/csghub/single-node.sh
else
    bash /etc/csghub/multi-node.sh
fi
