#!/bin/bash

echo "正在清理 pip 缓存..."
pip cache purge
rm -rf ~/.cache/pip

echo "正在清理 apt 缓存..."
sudo apt clean
sudo apt autoclean

echo "正在清理 ComfyUI 输出目录..."
rm -rf /root/ComfyUI/output
rm -rf /root/ComfyUI/temp

echo "正在清理 webos 登陆记录..."
bash /chenyudata/scripts/clean_webos.sh