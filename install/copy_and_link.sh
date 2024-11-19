#!/bin/bash

# 处理单个文件或软链接
handle_file() {
    local src="$1"
    local dst="$2"
    
    # 如果源文件是软链接
    if [ -L "$src" ]; then
        # 获取软链接的目标
        local link_target=$(readlink -f "$src")
        # 复制软链接到目标位置
        cp -P "$src" "$dst"
    else
        # 为普通文件创建软链接
        ln -sf "$(readlink -f "$src")" "$dst"
    fi
}

# 递归处理目录
process_directory() {
    local src_dir="$1"
    local dst_dir="$2"
    local rel_path="$3"
    
    # 遍历源目录中的所有项目
    for item in "$src_dir"/*; do
        # 跳过如果项目不存在
        [ -e "$item" ] || continue
        
        local base_name=$(basename "$item")
        local new_rel_path="${rel_path:+$rel_path/}$base_name"
        local dst_path="$dst_dir/$new_rel_path"
        
        if [ -d "$item" ] && [ ! -L "$item" ]; then
            # 如果是目录（且不是软链接），递归处理
            process_directory "$item" "$dst_dir" "$new_rel_path"
        else
            # 处理文件或软链接
            handle_file "$item" "$dst_path"
        fi
    done
}

# 主程序
if [ "$#" -ne 2 ]; then
    echo "用法: $0 <源目录> <目标目录>"
    exit 1
fi

src_dir="$(readlink -f "$1")"
dst_dir="$(readlink -f "$2")"

# 检查源目录
if [ ! -d "$src_dir" ]; then
    echo "错误: 源目录 '$src_dir' 不存在"
    exit 1
fi

echo "第1步: 复制目录结构..."
# 使用copy_tree_without_file.sh复制目录结构
./copy_tree_without_file.sh "$src_dir" "$dst_dir"

if [ $? -ne 0 ]; then
    echo "复制目录结构失败"
    exit 1
fi

echo "第2步: 创建文件链接..."
# 处理所有文件和软链接
process_directory "$src_dir" "$dst_dir"

echo "完成！目录结构已复制，文件已链接。" 