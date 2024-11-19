#!/bin/bash

set -e  # 遇到错误立即退出
exec 1> >(tee -a "/var/log/webos_restart.log") 2>&1  # 记录日志

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

# 停止 WebOS
stop_webos() {
    log "正在停止 WebOS..."
    
    # 使用 fuser 终止占用 7002 端口的进程
    if fuser 7002/tcp &> /dev/null; then
        log "终止占用 7002 端口的进程..."
        fuser -k 7002/tcp
        sleep 2
        log "端口 7002 已释放"
    else
        log "端口 7002 未被占用"
    fi
}

# 重启 WebOS
restart_webos() {
    # 检查并安装 fuser
    check_fuser
    
    # 停止服务
    stop_webos
    
    # 启动服务
    log "正在重启 WebOS..."
    bash /chenyudata/scripts/start/start_webos.sh
}

# 执行重启
restart_webos 