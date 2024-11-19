#!/bin/bash

set -e  # 遇到错误立即退出
exec 1> >(tee -a "/var/log/migrate_large_files.log") 2>&1  # 记录日志

# 添加时间戳函数
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

# 定义常量
ROOT_DIR="/root"
POD_DATA="/poddata"
MIN_SIZE=$((200 * 1024)) # 200MB in KB
SCRIPT_DIR="$(dirname "$0")"

# 在 main 函数之前添加
show_usage() {
    echo "用法: $0 [选项]"
    echo "选项:"
    echo "  -h, --help     显示此帮助信息"
    echo "  -s, --size     设置最小文件大小（KB），默认 200MB"
    echo "  -d, --dir      设置目标目录，默认 /poddata"
}

# 在 main 函数开始处添加
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_usage
            exit 0
            ;;
        -s|--size)
            MIN_SIZE=$2
            shift 2
            ;;
        -d|--dir)
            POD_DATA=$2
            shift 2
            ;;
        *)
            echo "错误: 未知参数 $1"
            show_usage
            exit 1
            ;;
    esac
done

# 检查必要的命令
check_requirements() {
    local commands=("find" "du" "dirname")
    for cmd in "${commands[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            echo "错误: 未找到必要的命令: $cmd"
            exit 1
        fi
    done
    
    # 检查依赖脚本
    if [ ! -f "$SCRIPT_DIR/copy_tree_without_file.sh" ]; then
        echo "错误: 未找到必要的脚本: copy_tree_without_file.sh"
        exit 1
    fi
    
    if [ ! -x "$SCRIPT_DIR/copy_tree_without_file.sh" ]; then
        echo "错误: copy_tree_without_file.sh 没有执行权限"
        exit 1
    fi
}

# 创建目标目录结构
create_target_structure() {
    local src_dir="$1"
    local dst_dir="$2"
    
    log "创建目录结构: $src_dir -> $dst_dir"
    bash "$SCRIPT_DIR/copy_tree_without_file.sh" "$src_dir" "$dst_dir"
}

# 处理单个大文件
process_large_file() {
    local file="$1"
    local src_dir="$2"
    local dst_dir="$3"
    
    # 检查文件路径是否包含 .git
    if [[ "$file" == *".git"* ]]; then
        log "跳过 .git 目录中的文件: $file"
        return 0
    fi
    
    # 计算相对路径
    local rel_path="${file#$src_dir/}"
    local target_file="$dst_dir/$rel_path"
    local target_dir="$(dirname "$target_file")"
    
    log "处理大文件: $file"
    log "目标位置: $target_file"
    
    # 确保目标目录存在
    mkdir -p "$target_dir"
    
    # 如果文件已经是软链接，跳过
    if [ -L "$file" ]; then
        log "文件已经是软链接，跳过: $file"
        return 0
    fi
    
    # 移动文件并创建软链接
    if mv "$file" "$target_file"; then
        if ln -s "$target_file" "$file"; then
            log "成功处理: $file"
        else
            log "错误: 无法创建软链接，正在回滚..."
            mv "$target_file" "$file"
            return 1
        fi
    else
        log "错误: 无法移动文件 $file"
        return 1
    fi
}

# 处理单个目录
process_directory() {
    local dir="$1"
    local base_name="$(basename "$dir")"
    local target_dir="$POD_DATA/$base_name"
    
    log "处理目录: $dir"
    
    # 创建目标目录结构
    create_target_structure "$dir" "$target_dir"
    
    # 查找大文件并处理，排除 .git 目录
    while IFS= read -r file; do
        process_large_file "$file" "$dir" "$target_dir"
    done < <(find "$dir" -type f -size "+${MIN_SIZE}k" ! -path "*/\.*" ! -path "*/.git/*")
}

# 主程序
main() {
    # 检查要求
    check_requirements
    
    # 检查并创建 POD_DATA 目录
    if [ ! -d "$POD_DATA" ]; then
        mkdir -p "$POD_DATA"
    fi
    
    # 处理 /root 下的所有目录
    while IFS= read -r dir; do
        # 跳过 conda 相关目录
        if [[ "$dir" == *"conda"* ]]; then
            log "跳过 conda 目录: $dir"
            continue
        fi
        
        # 跳过隐藏目录
        if [[ "$(basename "$dir")" == .* ]]; then
            log "跳过隐藏目录: $dir"
            continue
        fi
        
        process_directory "$dir"
    done < <(find "$ROOT_DIR" -maxdepth 1 -type d ! -name ".*")
    
    log "迁移完成！"
}

# 执行主程序
main 