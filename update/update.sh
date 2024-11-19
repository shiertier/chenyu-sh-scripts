#!/bin/bash

# 导入公共函数库
# 定义常量
VERSION_FILE="/poddata/.chenyu_vision"
PODDATA_DIR="/poddata"
LATEST_VERSION=3

# 检查目录权限
check_write_permission() {
    if [ -w "$PODDATA_DIR" ]; then
        echo "true"
    else
        echo "false"
    fi
}

# 获取当前版本
get_current_version() {
    if [ -f "$VERSION_FILE" ]; then
        cat "$VERSION_FILE"
    else
        echo "0"
    fi
}

# 更新版本号
update_version() {
    local is_writable=$(check_write_permission)
    if [ "$is_writable" = "true" ]; then
        echo "$1" > "$VERSION_FILE"
        echo "版本号已更新到: $1"
    else
        echo "警告: 目录不可写入，跳过版本号更新"
    fi
}

# 执行特定版本的更新脚本
execute_version_update() {
    local version=$1
    local script_path="/chenyudata/scripts/versions/version_${version}.sh"
    
    if [ -f "$script_path" ]; then
        echo "执行版本 ${version} 的更新脚本..."
        source "$script_path"
        update_version "$version"
    else
        echo "错误: 找不到版本 ${version} 的更新脚本"
        exit 1
    fi
}

# 主要更新逻辑
main() {
    # 检查 vision 目录是否存在更新文件
    if [ ! -d "vision" ] || [ -z "$(ls -A vision 2>/dev/null)" ]; then
        return 0
    }

    local is_writable=$(check_write_permission)
    current_version=$(get_current_version)
    
    echo "当前版本: $current_version"
    echo "最新版本: $LATEST_VERSION"
    echo "目录写入权限: $([ "$is_writable" = "true" ] && echo "可写入" || echo "不可写入")"
    
    # 如果目录不可写入且版本文件不存在，使用版本0
    if [ ! -f "$VERSION_FILE" ]; then
        echo "警告: 版本文件不存在，将使用版本0进行更新"
    fi

    # 逐步执行更新
    while [ "$current_version" -lt "$LATEST_VERSION" ]; do
        next_version=$((current_version + 1))
        execute_version_update "$next_version"
        
        # 如果目录不可写入，手动更新当前版本变量
        if [ "$is_writable" = "false" ]; then
            current_version=$next_version
        else
            current_version=$(get_current_version)
        fi
    done

    if [ "$is_writable" = "true" ]; then
        echo "更新完成！当前版本: $(get_current_version)"
    else
        echo "更新完成！内容已更新但版本号未写入（目录不可写入）"
        echo "实际执行到版本: $current_version"
    fi
}

# 执行主函数
main