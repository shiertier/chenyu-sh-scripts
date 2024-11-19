#!/bin/bash

set -e  # 遇到错误立即退出
exec 1> >(tee -a "/var/log/jupyter_restart.log") 2>&1  # 记录日志

# 添加时间戳函数
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

# 检查 fuser 命令
check_fuser() {
    if ! command -v fuser &> /dev/null; then
        log "正在安装 fuser..."
        apt-get update && apt-get install -y psmisc
    fi
}

# 停止 Jupyter
stop_jupyter() {
    log "正在停止 Jupyter Lab..."
    
    # 使用 fuser 终止占用 8888 端口的进程
    if fuser 8888/tcp &> /dev/null; then
        log "终止占用 8888 端口的进程..."
        fuser -k 8888/tcp
        sleep 2
        log "端口 8888 已释放"
    else
        log "端口 8888 未被占用"
    fi
}

# 重启 Jupyter
restart_jupyter() {
    # 检查并安装 fuser
    check_fuser
    
    # 停止服务
    stop_jupyter
    
    # 启动服务
    log "正在重启 Jupyter Lab..."
    bash /chenyudata/scripts/start/start_jupyter.sh
}

# 执行重启
restart_jupyter 