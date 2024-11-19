#!/bin/bash

set -e  # 遇到错误立即退出
exec 1> >(tee -a "/var/log/webos_start.log") 2>&1  # 记录日志

# 添加时间戳函数
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

# 定义常量
WEBOS_DIR="/webos/api"

# 启动 WebOS
start_webos() {
    log "启动 WebOS..."
    
    # 切换到 WebOS 目录
    cd "$WEBOS_DIR"
    
    # 检查是否存在 check.sh
    if [ -f "check.sh" ]; then
        log "执行 check.sh..."
        bash check.sh
    else
        if [ -f "restart.sh" ]; then
            log "check.sh 不存在，执行 restart.sh..."
            bash restart.sh
        else
            log "错误: check.sh 和 restart.sh 都不存在"
            exit 1
        fi
    fi
    
    log "WebOS 已成功启动！"
}

main() {
    log "开始启动 WebOS 服务..."
    
    # 检查目录是否存在
    if [ ! -d "$WEBOS_DIR" ]; then
        log "错误: WebOS 目录不存在: $WEBOS_DIR"
        exit 1
    fi
    
    # 启动服务
    start_webos
}

# 执行主程序
main 