#!/bin/bash

# 检查是否只包含隐藏文件/目录
check_only_hidden() {
    local dir="$1"
    local has_visible=false
    
    # 遍历目录中的所有项目
    for item in "$dir"/*; do
        # 跳过如果没有匹配到任何文件
        [ -e "$item" ] || continue
        
        # 如果存在非隐藏项目
        if [[ ! $(basename "$item") =~ ^\. ]]; then
            has_visible=true
            break
        fi
    done
    
    # 如果只有隐藏文件，返回0（true）
    if [ "$has_visible" = false ]; then
        return 0
    else
        return 1
    fi
}

# 检查目录是否为空或只包含空目录
check_empty_or_only_empty_dirs() {
    local dir="$1"
    
    # 检查是否有任何文件
    if [ -z "$(find "$dir" -type f)" ]; then
        # 检查是否有非空目录
        for d in $(find "$dir" -type d); do
            # 跳过当前目录
            [ "$d" = "$dir" ] && continue
            
            # 如果目录不为空且不只包含空目录
            if [ -n "$(ls -A "$d")" ] && ! check_empty_or_only_empty_dirs "$d"; then
                return 1
            fi
        done
        return 0
    fi
    return 1
}

# 清理目录
clean_directory() {
    local dir="$1"
    local cleaned=false
    
    # 递归处理所有子目录
    while IFS= read -r -d '' subdir; do
        # 如果目录只包含隐藏文件/目录
        if check_only_hidden "$subdir"; then
            echo "清理包含隐藏文件的目录: $subdir"
            rm -rf "$subdir"/*
            cleaned=true
            continue
        fi
        
        # 如果目录为空或只包含空目录
        if check_empty_or_only_empty_dirs "$subdir"; then
            echo "删除空目录: $subdir"
            rm -rf "$subdir"
            cleaned=true
        fi
    done < <(find "$dir" -type d -print0)
    
    # 最后检查主目录
    if [ -d "$dir" ] && check_only_hidden "$dir"; then
        echo "清理主目录中的隐藏文件: $dir"
        rm -rf "$dir"/*
        cleaned=true
    fi
    
    if [ "$cleaned" = true ]; then
        echo "清理完成"
    else
        echo "没有需要清理的目录"
    fi
}

# 主程序
if [ "$#" -ne 1 ]; then
    echo "用法: $0 <目标目录>"
    exit 1
fi

target_dir="$1"

if [ ! -d "$target_dir" ]; then
    echo "错误: 目录 '$target_dir' 不存在"
    exit 1
fi

echo "开始清理目录: $target_dir"
clean_directory "$target_dir" 