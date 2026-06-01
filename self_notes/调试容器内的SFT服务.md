让我检查容器的运行状态和端口监听情况：

 
          
容器运行完全正常！让我总结一下当前状态：

## ✅ 运行状态总结

| 服务 | 状态 | 端口 | 说明 |
|------|------|------|------|
| **容器** | ✅ 运行中 | - | 已运行2小时 |
| **Jupyter Lab** | ✅ 正常 | 8000 | 可访问 http://localhost:8000/lab |
| **Llama-Factory WebUI** | ✅ 正常 | 7860 | 可访问 http://localhost:7860 |
| **内存监控** | ✅ 正常 | - | 后台运行 |

## 📋 日志分析

从日志可以看到：
1. **所有服务启动成功**：supervisord 成功启动了 jupyter、llama-factory、mem-monitor 三个进程
2. **Jupyter Lab**：正常运行在 `http://127.0.0.1:8000/lab`
3. **Llama-Factory**：显示 "Visit http://ip:port for Web UI, e.g., http://127.0.0.1:7860"
4. **端口测试**：nc 测试显示端口 7860 连接成功

## 🔧 如果你无法访问服务

请检查以下几点：

### 1. 检查端口占用
```bash
netstat -tlnp | grep -E "8000|7860"
```

### 2. 测试本地连接
```bash
curl http://localhost:8000/lab/api/settings
curl http://localhost:7860/
```

### 3. 检查防火墙设置
```bash
sudo ufw status
```

### 4. 尝试重启容器
```bash
docker stop llama-factory-container
./run.sh
```

## 🎯 下一步操作

容器已就绪，你可以：

1. **访问 Jupyter Lab**: http://localhost:8000/lab
2. **访问 Llama-Factory WebUI**: http://localhost:7860
3. **进入容器执行命令**: 
   ```bash
   docker exec -it llama-factory-container bash
   ```
4. **运行命令行训练**:
   ```bash
   docker exec -it llama-factory-container bash -c "CUDA_VISIBLE_DEVICES=0 llamafactory-cli train --stage sft --model_name_or_path Qwen/Qwen2-0.5B --dataset phone_en"
   ```

**运行是成功的！** 如果仍然无法访问，请告诉我具体的错误信息或现象。