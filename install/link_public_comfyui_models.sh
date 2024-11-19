#!/bin/bash

# 定义源目录和目标目录
CHENYU_MODELS="/chenyuda/ComfyUI/models"
ROOT_MODELS="/root/ComfyUI/models"

# 检查目录是否存在
check_directories() {
    if [ ! -d "$CHENYU_MODELS" ]; then
        echo "错误: 源目录不存在: $CHENYU_MODELS"
        return 1
    fi

    if [ ! -d "$ROOT_MODELS" ]; then
        echo "错误: 目标目录不存在: $ROOT_MODELS"
        return 1
    fi

    return 0
}

# 检查两个目录是否都存在
echo "检查目录..."
if ! check_directories; then
    echo "错误: 请确保两个目录都存在后再执行"
    exit 1
fi

echo "开始同步公共 ComfyUI 模型目录..."

# 首先复制目录结构
echo "第1步: 复制目录结构..."
sudo ./copy_tree_without_file.sh "$CHENYU_MODELS" "$ROOT_MODELS"

if [ $? -ne 0 ]; then
    echo "错误: 复制目录结构失败"
    exit 1
fi

# 然后创建文件链接
echo "第2步: 创建文件链接..."
sudo ./copy_and_link.sh "$CHENYU_MODELS" "$ROOT_MODELS"

if [ $? -ne 0 ]; then
    echo "错误: 创建文件链接失败"
    exit 1
fi

echo "完成！公共 ComfyUI 模型目录已同步"
echo "源目录: $CHENYU_MODELS"
echo "目标目录: $ROOT_MODELS" 