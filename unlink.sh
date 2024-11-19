rm -rf /root/.cache/torch/hub/checkpoints/alexnet-owt-7be5be79.pth
rm -rf /root/ComfyUI/models/Joy_caption_alpha

echo "移除所有软链接..."
sudo find "/root/ComfyUI/models" -type l -delete
sudo find "/root/ComfyUI/custom_nodes/ComfyUI-IDM-VTON/models" -type l -delete
sudo find "/root/ComfyUI/custom_nodes/ComfyUI-BRIA_AI-RMBG/RMBG-1.4" -type l -delete

for i in {1..50}
do
    find /root/ComfyUI/models -mindepth 2 -type d \( -empty -o -exec test -d {}/.git \; \) -exec rmdir {} +
done