#!/bin/bash

fuser -k 8188/tcp

cd /root/ComfyUI
python main.py --output-directory /appdata/output/ --input-directory /appdata/input/ --listen 0.0.0.0
