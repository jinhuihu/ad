#!/bin/bash
# 手动下载并安装 Android SDK Build-Tools 30.0.3
# 解决从 Google 官方下载速度慢的问题

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=========================================="
echo "  Android Build-Tools 30.0.3 安装工具"
echo "==========================================${NC}"
echo ""

# 获取 SDK 路径
SDK_DIR="/Users/hujinhui/Library/Android/sdk"
BUILD_TOOLS_DIR="$SDK_DIR/build-tools/30.0.3"

# 检查是否已安装
if [ -d "$BUILD_TOOLS_DIR" ]; then
    echo -e "${GREEN}✓ Build-Tools 30.0.3 已经安装${NC}"
    echo "位置: $BUILD_TOOLS_DIR"
    ls -la "$BUILD_TOOLS_DIR" | head -10
    exit 0
fi

echo -e "${YELLOW}未检测到 Build-Tools 30.0.3${NC}"
echo ""
echo "提供以下解决方案："
echo ""
echo "方案1: 使用 sdkmanager 配合国内镜像安装（推荐）"
echo "方案2: 从国内镜像手动下载并安装"
echo "方案3: 使用 Android Studio SDK Manager"
echo ""

# 方案1：使用 sdkmanager
install_with_sdkmanager() {
    echo -e "${YELLOW}[方案1] 使用 sdkmanager 安装...${NC}"
    echo ""
    
    SDKMANAGER="$SDK_DIR/cmdline-tools/latest/bin/sdkmanager"
    
    # 检查 sdkmanager 是否存在
    if [ ! -f "$SDKMANAGER" ]; then
        # 尝试其他可能的位置
        SDKMANAGER="$SDK_DIR/tools/bin/sdkmanager"
        if [ ! -f "$SDKMANAGER" ]; then
            echo -e "${YELLOW}未找到 sdkmanager，尝试方案2${NC}"
            return 1
        fi
    fi
    
    echo "找到 sdkmanager: $SDKMANAGER"
    echo "开始安装 build-tools;30.0.3..."
    echo ""
    
    # 使用 yes 自动接受许可证
    yes | "$SDKMANAGER" "build-tools;30.0.3" --sdk_root="$SDK_DIR" || true
    
    # 检查是否安装成功
    if [ -d "$BUILD_TOOLS_DIR" ]; then
        echo -e "${GREEN}✓ Build-Tools 30.0.3 安装成功！${NC}"
        return 0
    else
        echo -e "${YELLOW}安装可能失败，尝试方案2${NC}"
        return 1
    fi
}

# 方案2：提供手动下载指引
manual_download_guide() {
    echo -e "${YELLOW}[方案2] 手动下载安装指引${NC}"
    echo ""
    echo "由于直接下载速度慢，请按以下步骤操作："
    echo ""
    echo -e "${BLUE}步骤1: 从国内镜像下载${NC}"
    echo "请访问以下任一镜像站："
    echo ""
    echo "选项A - 清华大学镜像："
    echo "  https://mirrors.tuna.tsinghua.edu.cn/android/repository/"
    echo "  下载文件: build-tools_r30.0.3-macosx.zip"
    echo ""
    echo "选项B - 阿里云镜像："
    echo "  https://developer.aliyun.com/mirror/android"
    echo ""
    echo "选项C - 腾讯云镜像："
    echo "  https://mirrors.cloud.tencent.com/AndroidSDK/"
    echo ""
    echo -e "${BLUE}步骤2: 解压并安装${NC}"
    echo "下载完成后，运行以下命令："
    echo ""
    echo "  # 假设下载的文件在 ~/Downloads/"
    echo "  mkdir -p \"$SDK_DIR/build-tools/30.0.3\""
    echo "  unzip ~/Downloads/build-tools_r30.0.3-macosx.zip -d \"$SDK_DIR/build-tools/30.0.3\""
    echo ""
    echo -e "${BLUE}步骤3: 验证安装${NC}"
    echo "  ls -la \"$SDK_DIR/build-tools/30.0.3\""
    echo ""
    echo -e "${YELLOW}提示：如果文件名不同，请根据实际文件名调整命令${NC}"
    echo ""
}

# 方案3：使用 Android Studio
android_studio_guide() {
    echo -e "${YELLOW}[方案3] 使用 Android Studio SDK Manager${NC}"
    echo ""
    echo "1. 打开 Android Studio"
    echo "2. 进入 Tools -> SDK Manager"
    echo "3. 切换到 SDK Tools 标签"
    echo "4. 勾选 'Android SDK Build-Tools 30.0.3'"
    echo "5. 点击 Apply 并等待下载完成"
    echo ""
    echo "如果下载很慢，确保已配置镜像源（运行 ./配置Android镜像.sh）"
    echo ""
}

# 尝试自动安装
echo -e "${GREEN}尝试自动安装...${NC}"
echo ""

if install_with_sdkmanager; then
    echo ""
    echo -e "${GREEN}=========================================="
    echo "  安装成功！"
    echo "==========================================${NC}"
    exit 0
fi

# 如果自动安装失败，显示手动指引
echo ""
echo -e "${YELLOW}=========================================="
echo "  需要手动操作"
echo "==========================================${NC}"
echo ""

manual_download_guide
echo ""
android_studio_guide

echo ""
echo -e "${BLUE}推荐操作流程：${NC}"
echo "1. 从清华镜像手动下载 build-tools_r30.0.3-macosx.zip"
echo "2. 解压到 SDK 目录"
echo "3. 重新运行编译脚本"
echo ""
echo "如需帮助，请查看：Android_SDK_加速配置指南.md"

