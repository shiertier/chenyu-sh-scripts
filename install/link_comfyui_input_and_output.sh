#!/bin/bash

# 定义基础目录
ROOT_COMFYUI="/root/ComfyUI"
APPDATA_DIR="/appdata"

# 定义需要处理的目录
DIRS=(
    "input"
    "output"
)

# 主程序开始
echo "开始处理 ComfyUI 的 input 和 output 目录..."

# 检查 root/ComfyUI 目录是否存在
if [ ! -d "$ROOT_COMFYUI" ]; then
    echo "错误: ComfyUI 目录不存在: $ROOT_COMFYUI"
    exit 1
fi

# 处理每个目录
for dir in "${DIRS[@]}"; do
    SOURCE_PATH="$ROOT_COMFYUI/$dir"
    TARGET_NAME="$dir"
    
    echo "处理 $dir 目录..."
    
    # 调用 move_and_link.sh 脚本
    if ! bash "$(dirname "$0")/move_and_link.sh" "$SOURCE_PATH" "$TARGET_NAME"; then
        echo "错误: 处理 $dir 目录时失败"
        exit 1
    fi
    
    echo "$dir 目录处理完成"
done

echo "完成！"
echo "已处理以下目录："
for dir in "${DIRS[@]}"; do
    echo "- $ROOT_COMFYUI/$dir -> $APPDATA_DIR/$dir"
done 