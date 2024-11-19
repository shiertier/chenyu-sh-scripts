# webos文档

## 脚本介绍

### /root/start.sh

镜像启动时，自动运行start.sh脚本
脚本将依次执行

- preper.sh: 创建`用户目录`，`POD目录`下的ComfyUI模型目录
- clean_webos.sh: 清空os访问记录
- start_jupyter.sh: 启动Jupyter Lab
- check.sh: 启动webos
- link.sh: 挂载`POD目录`和`用户目录`下的ComfyUI模型目录的软链接
- restart.sh: 同步`用户目录`下的ComfyUI输入输出目录，启动ComfyUI

### /chenyudata/scripts/ComfyUI/preper.sh

启动时，自动运行preper.sh脚本，创建`用户目录`，`POD目录`下的ComfyUI模型目录

### /chenyudata/scripts/clean_webos.sh

清除webos登陆记录

### /chenyudata/scripts/start_jupyter.sh

镜像启动时，自动运行start_jupyter.sh脚本，启动Jupyter Lab

### /webos/api/check.sh

启动webos并持续检测webos状态

### /root/link.sh

启动时，按link.sh 的逻辑处理软链接

### /chenyudata/scripts/restart.sh

镜像启动时，自动运行restart.sh脚本，同步`用户目录`下的ComfyUI输入输出目录，启动ComfyUI
也可以手动执行restart.sh脚本来重启ComfyUI

### /chenyudata/scripts/unlink.sh

镜像制作时，手动运行unlink.sh脚本，可以删除`用户目录`下的ComfyUI模型目录的软链接

### /chenyudata/scripts/linkusrdata.sh

镜像制作时，手动运行linkusrdata.sh脚本，创建`用户目录`下的ComfyUI模型目录的软链接

### /chenyudata/scripts/clean.sh

镜像制作完成后，运行clean.sh脚本，清理pip缓存、apt缓存、ComfyUI输出目录、webos登陆记录

## 模型放置

### KOL用户

应该将模型放置在`/poddata/ComfyUI/models`目录下
例如：
`sd1.5`模型放置在`/poddata/ComfyUI/models/checkpoints/sd1.5.safetensors`
`flux.1.safetensors`模型放置在`/poddata/ComfyUI/models/unet/flux.1.safetensors`

也就是说，如果文件放置在`/poddata/ComfyUI/models`目录下，就会在启动时（或者手动执行bash /root/link.sh时）以相同的结构挂载到`/root/ComfyUI/models`目录下

### 普通用户

#### 1. 常见模型放置

用户目录`/usrdata`下的三个目录：

- `checkpoints`：放置checkpoint模型 -> 对应`/root/ComfyUI/models/checkpoints/private`
- `loras`：放置lora模型 -> 对应`/root/ComfyUI/models/loras/private`
- `unet`：放置unet模型 -> 对应`/root/ComfyUI/models/unet/private`

#### 2. 通用模型放置

用户目录`/usrdata`下的`ComfyUI/models`目录：

- `checkpoints`：放置checkpoint模型 -> 对应`/root/ComfyUI/models/checkpoints`
- `loras`：放置lora模型 -> 对应`/root/ComfyUI/models/loras`
- `unet`：放置unet模型 -> 对应`/root/ComfyUI/models/unet`
- 其他目录：放置其他模型 -> 对应`/root/ComfyUI/models/{model_type}`  

注：{model_type} 为模型类型
