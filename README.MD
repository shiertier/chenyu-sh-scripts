# WebOS 部署工具集

这是一个用于WebOS系统部署和维护的工具集合，提供了一系列脚本来自动化系统的安装、配置和维护工作。

## 目录结构

```text
.
├── install/          # 安装和配置相关脚本
├── start/           # 服务启动相关脚本  
└── update/          # 系统更新相关脚本
```

## 功能模块

### 1. 安装配置模块 (install/)

#### 目录管理工具

- **clean_empty_dirs.sh**
  - 功能：清理空目录和只包含隐藏文件的目录
  - 用法：`./clean_empty_dirs.sh <目标目录>`

- **copy_tree_without_file.sh**
  - 功能：复制目录结构(不包含文件)
  - 用法：`./copy_tree_without_file.sh <源目录> <目标目录>`

- **copy_and_link.sh**
  - 功能：复制目录结构并创建文件软链接
  - 用法：`./copy_and_link.sh <源目录> <目标目录>`

#### ComfyUI相关工具

- **link_comfyui_input_and_output.sh**
  - 功能：管理ComfyUI的输入输出目录
  - 作用：将input和output目录移至/appdata并创建软链接

- **link_public_comfyui_models.sh**
  - 功能：同步公共ComfyUI模型目录
  - 作用：在/root/ComfyUI/models和/chenyuda/ComfyUI/models间建立链接

- **link_pod_comfyui_models.sh**
  - 功能：同步Pod环境ComfyUI模型
  - 作用：在/poddata/ComfyUI/models和/chenyuda/ComfyUI/models间建立链接

- **link_usr_comfyui_models.sh**
  - 功能：同步Usr环境ComfyUI模型
  - 作用：在/usrdata/ComfyUI/models和/chenyuda/ComfyUI/models间建立链接

- **preper_comfyui_privite.sh**
  - 功能：准备ComfyUI私有模型目录
  - 作用：创建私有模型目录结构并建立必要的软链接

#### 系统工具

- **migrate_large_files.sh**
  - 功能：迁移大文件
  - 用法：`./migrate_large_files.sh [选项]`
  - 选项：
    - `-s, --size`: 设置最小文件大小(KB)
    - `-d, --dir`: 设置目标目录

- **move_and_link.sh**
  - 功能：移动目录并创建软链接
  - 用法：`./move_and_link.sh <源路径> <目标名称>`

- **clean.sh**
  - 功能：系统清理工具
  - 作用：清理pip缓存、apt缓存、临时文件等

### 2. 服务启动模块 (start/)

- **restart_comfyui.sh**
  - 功能：终止8188端口的进程并重新启动ComfyUI

- **restart_jupyter.sh**
  - 功能：终止占用8888端口的进程并重启Jupyter

- **start_jupyter.sh**
  - 功能：启动Jupyter服务

- **restart_webos.sh**
  - 功能：终止占用7002端口的进程并重启WebOS

- **start_webos.sh**
  - 功能：启动WebOS服务

### 3. 更新模块 (update/)

- **update.sh**
  - 功能：系统版本更新工具
  - 作用：
    - 检查当前版本
    - 执行版本更新脚本
    - 更新版本号

## 系统要求

- Ubuntu操作系统
- Bash shell环境
- sudo权限
- 必要的系统工具(如rsync，将在需要时自动安装)

## 使用建议

1. 首次部署时，建议按以下顺序执行：

   ```bash
   # 1. 准备系统环境
   ./install/preper.sh
   
   # 2. 配置ComfyUI
   ./install/preper_comfyui_privite.sh
   ./install/link_comfyui_input_and_output.sh
   
   # 3. 启动服务
   ./start/start_webos.sh
   ```

2. 日常维护：

   ```bash
   # 清理系统
   ./install/clean.sh
   
   # 更新系统
   ./update/update.sh
   ```

3. 服务重启：

   ```bash
   # 重启WebOS
   ./start/restart_webos.sh
   
   # 重启Jupyter
   ./start/restart_jupyter.sh
   ```

## 注意事项

- 执行脚本前请确保有相应的权限
- 建议在执行重要操作前进行数据备份
- 部分脚本会自动安装所需的依赖项
