#!/bin/bash

set -e  # 遇到错误立即退出
exec 1> >(tee -a "/var/log/jupyter_start.log") 2>&1  # 记录日志

# 添加时间戳函数
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

# 定义常量
JUPYTER_CONFIG_DIR="/root/.jupyter"
JUPYTER_LAB_SETTINGS_DIR="$JUPYTER_CONFIG_DIR/lab/user-settings/@jupyterlab/translation-extension"
JUPYTER_CONFIG_FILE="$JUPYTER_CONFIG_DIR/jupyter_lab_config.py"
TRANSLATION_SETTINGS_FILE="$JUPYTER_LAB_SETTINGS_DIR/plugin.jupyterlab-settings"

# 检查必要的命令
check_requirements() {
    local commands=("jupyter" "nohup")
    for cmd in "${commands[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            log "错误: 未找到必要的命令: $cmd"
            exit 1
        fi
    done
}

# 配置 Jupyter
setup_jupyter() {
    log "开始配置 Jupyter Lab..."
    
    # 清理旧配置
    if [ -d "$JUPYTER_CONFIG_DIR" ]; then
        log "清理旧的 Jupyter 配置..."
        rm -rf "$JUPYTER_CONFIG_DIR"
    fi
    
    # 生成新配置
    log "生成新的配置文件..."
    jupyter lab --generate-config
    
    # 写入配置
    cat >> "$JUPYTER_CONFIG_FILE" << EOF
c.ServerApp.token = 'Zeyun1234'
c.ServerApp.allow_origin = '*'
c.ServerApp.terminado_settings = {'shell_command' : ['/bin/bash']}
EOF
    
    # 配置中文界面
    log "配置中文界面..."
    mkdir -p "$JUPYTER_LAB_SETTINGS_DIR"
    echo '{"locale": "zh_CN"}' > "$TRANSLATION_SETTINGS_FILE"
}

# 启动 Jupyter
start_jupyter() {
    log "启动 Jupyter Lab..."
    
    # 启动新实例
    log "启动新的 Jupyter Lab 实例..."
    nohup jupyter lab \
        --allow-root \
        --ip 0.0.0.0 \
        --port 8888 \
        --no-browser \
        > /var/log/jupyter.log 2>&1 &
    
    # 等待服务启动
    local max_attempts=30
    local attempt=0
    while ! curl -s http://localhost:8888 > /dev/null; do
        attempt=$((attempt + 1))
        if [ $attempt -ge $max_attempts ]; then
            log "错误: Jupyter Lab 启动超时"
            exit 1
        fi
        log "等待 Jupyter Lab 启动... ($attempt/$max_attempts)"
        sleep 1
    done
    
    log "Jupyter Lab 已成功启动！"
    log "访问地址: http://localhost:8888"
    log "访问令牌: Zeyun1234"
}

main() {
    log "开始启动 Jupyter Lab 服务..."
    
    # 检查依赖
    check_requirements
    
    # 配置 Jupyter
    setup_jupyter
    
    # 启动服务
    start_jupyter
}

# 执行主程序
main