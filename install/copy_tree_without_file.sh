#!/bin/bash

# 检查并安装rsync
check_and_install_rsync() {
    if ! command -v rsync &> /dev/null; then
        echo "rsync 未安装，正在尝试安装..."
        sudo apt-get update && sudo apt-get install -y rsync
        
        if [ $? -eq 0 ]; then
            echo "rsync 安装成功"
        else
            echo "rsync 安装失败"
            exit 1
        fi
    fi
}

# 检查参数数量
if [ "$#" -ne 2 ]; then
    echo "用法: $0 <源目录> <目标目录>"
    exit 1
fi

# 确保rsync已安装
check_and_install_rsync

src_dir="$1"
dst_dir="$2"

# 检查源目录是否存在
if [ ! -d "$src_dir" ]; then
    echo "错误: 源目录 '$src_dir' 不存在"
    exit 1
fi

# 检查目标目录是否存在，如果不存在则创建
if [ ! -d "$dst_dir" ]; then
    echo "创建目标目录 '$dst_dir'"
    mkdir -p "$dst_dir"
fi

echo "正在从 $src_dir 复制目录结构到 $dst_dir ..."

# 使用rsync复制目录结构
# --include='*/' 包含所有目录
# --exclude='*' 排除所有文件
# -a 保持权限等属性
# -v 显示详细信息
sudo rsync -av --include='*/' --exclude='*' "$src_dir/" "$dst_dir/"

if [ $? -eq 0 ]; then
    echo "目录结构复制完成"
else
    echo "复制过程中发生错误"
    exit 1
fi
