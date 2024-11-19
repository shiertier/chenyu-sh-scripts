#!/bin/bash

# 定义基础目录
PODDATA_DIR="/poddata"
ROOT_MODELS="/root/ComfyUI/models"
USRDATA_DIR="/usrdata"

# 定义目录结构
USRDATA_DIRS=(
    "checkpoints"
    "loras"
    "unet"
)

# 检查poddata目录是否可写
check_poddata_writable() {
    if ! touch "$PODDATA_DIR/test_write" 2>/dev/null; then
        echo "错误: $PODDATA_DIR 目录不可写"
        return 1
    fi
    rm -f "$PODDATA_DIR/test_write"
    return 0
}

# 检查目录是否存在
check_directory() {
    local dir="$1"
    if [ -d "$dir" ]; then
        echo "目录已存在: $dir"
        return 0
    fi
    return 1
}

# 创建目录
create_directory() {
    local base_dir="$1"
    local sub_dir="$2"
    local full_path="${base_dir}/${sub_dir}"
    
    if check_directory "$full_path"; then
        return 0
    fi
    
    echo "创建目录: $full_path"
    if ! mkdir -p "$full_path"; then
        echo "错误: 无法创建目录 $full_path"
        return 1
    fi
    return 0
}

# 创建软链接
create_symlink() {
    local src_dir="$1"
    local target_dir="$2"
    local sub_dir="$3"
    
    local src_path="${src_dir}/${sub_dir}"
    local target_path="${target_dir}/${sub_dir}/private"
    
    echo "检查软链接: $src_path"
    if [ -L "$src_path" ]; then
        echo "警告: 软链接已存在，正在更新..."
        rm -f "$src_path"
    fi
    
    # 尝试链接到 private
    if [ -d "$target_path" ]; then
        echo "创建软链接: $src_path -> $target_path"
        if ! ln -s "$target_path" "$src_path"; then
            echo "错误: 无法创建软链接 $src_path"
            return 1
        fi

    return 0
}

# 主程序开始
echo "开始准备 ComfyUI 私有模型目录..."

# 检查 poddata 目录是否可写
echo "检查 poddata 目录权限..."
if ! check_poddata_writable; then
    exit 1
fi

# 创建 usrdata 中的目录结构（如果不存在）
echo "检查并创建 usrdata 目录结构..."
for dir in "${USRDATA_DIRS[@]}"; do
    if ! create_directory "$USRDATA_DIR" "$dir"; then
        exit 1
    fi
done

# 创建从 usrdata 到 root/private 的软链接
echo "创建软链接..."
for dir in "${USRDATA_DIRS[@]}"; do
    if ! create_symlink "$USRDATA_DIR" "$ROOT_MODELS" "$dir"; then
        exit 1
    fi
done

echo "完成！ComfyUI 私有模型目录已准备就绪"
echo "已创建以下目录结构："
echo "在 usrdata 中:"
for dir in "${USRDATA_DIRS[@]}"; do
    target_path="$ROOT_MODELS/$dir/private"
    old_target_path="$ROOT_MODELS/$dir/privite"
    if [ -d "$target_path" ]; then
        echo "- $USRDATA_DIR/ComfyUI/models/$dir -> $target_path"
    elif [ -d "$old_target_path" ]; then
        echo "- $USRDATA_DIR/ComfyUI/models/$dir -> $old_target_path"
    fi
done 