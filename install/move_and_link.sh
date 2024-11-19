#!/bin/bash

# 检查参数
if [ "$#" -ne 2 ]; then
    echo "用法: $0 <源路径> <目标路径>"
    exit 1
fi

SOURCE_PATH="$1"
TARGET_PATH="$2"
APPDATA_DIR="/appdata"

# 获取目录基础名称
BASE_NAME=$(basename "$SOURCE_PATH")
APPDATA_TARGET="$APPDATA_DIR/$BASE_NAME"

# 检查 appdata 目录是否存在，不存在则创建
if [ ! -d "$APPDATA_DIR" ]; then
    echo "创建 appdata 目录..."
    if ! mkdir -p "$APPDATA_DIR"; then
        echo "错误: 无法创建 appdata 目录"
        exit 1
    fi
fi

# 如果源目录存在
if [ -d "$SOURCE_PATH" ]; then
    echo "源目录存在，开始移动..."
    
    # 如果 appdata 目标已存在，先备份
    if [ -e "$APPDATA_TARGET" ]; then
        BACKUP_NAME="$APPDATA_TARGET.backup.$(date +%Y%m%d_%H%M%S)"
        echo "目标位置已存在，创建备份: $BACKUP_NAME"
        if ! mv "$APPDATA_TARGET" "$BACKUP_NAME"; then
            echo "错误: 无法创建备份"
            exit 1
        fi
    fi
    
    # 移动目录到 appdata
    echo "移动 $SOURCE_PATH 到 $APPDATA_TARGET"
    if ! mv "$SOURCE_PATH" "$APPDATA_TARGET"; then
        echo "错误: 无法移动目录"
        exit 1
    fi
    
else
    echo "源目录不存在，创建新目录..."
    if ! mkdir -p "$APPDATA_TARGET"; then
        echo "错误: 无法创建目标目录"
        exit 1
    fi
fi

# 创建软链接
echo "创建软链接: $SOURCE_PATH -> $APPDATA_TARGET"
if [ -L "$SOURCE_PATH" ]; then
    echo "删除已存在的软链接..."
    rm -f "$SOURCE_PATH"
fi

if ! ln -s "$APPDATA_TARGET" "$SOURCE_PATH"; then
    echo "错误: 无法创建软链接"
    exit 1
fi

echo "完成！"
echo "目录已移动/创建: $APPDATA_TARGET"
echo "软链接已创建: $SOURCE_PATH -> $APPDATA_TARGET" 