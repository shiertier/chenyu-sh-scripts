#!/bin/bash

echo "开始创建必要目录..."

# 创建 usrdata 下的目录
mkdir -p /usrdata/checkpoints
mkdir -p /usrdata/loras
mkdir -p /usrdata/unet

# 创建 poddata 下的目录（忽略错误）
mkdir -p /poddata/ComfyUI/models/checkpoints 2>/dev/null || true
mkdir -p /poddata/ComfyUI/models/loras 2>/dev/null || true
mkdir -p /poddata/ComfyUI/models/unet 2>/dev/null || true