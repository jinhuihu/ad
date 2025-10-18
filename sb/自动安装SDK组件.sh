#!/bin/bash
# 自动从国内镜像下载并安装 Android SDK 组件
# 解决 Build-Tools 30.0.3 下载卡住的问题

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=========================================="
echo "  自动安装 Android SDK 组件"
echo "==========================================${NC}"
echo ""

# 配置
SDK_DIR="/Users/hujinhui/Library/Android/sdk"
TEMP_DIR="/tmp/android-sdk-downloads"
BUILD_TOOLS_VERSION="30.0.3"
PLATFORM_VERSION="30"

# 清华镜像地址
MIRROR_BASE="https://mirrors.tuna.tsinghua.edu.cn/android/repository"

# 创建临时目录
mkdir -p "$TEMP_DIR"
cd "$TEMP_DIR"

echo "临时下载目录: $TEMP_DIR"
echo "SDK 安装目录: $SDK_DIR"
echo ""

# 下载 Build-Tools 30.0.3
install_build_tools() {
    local build_tools_dir="$SDK_DIR/build-tools/$BUILD_TOOLS_VERSION"
    
    if [ -d "$build_tools_dir" ] && [ "$(ls -A "$build_tools_dir" | grep -v .installer | wc -l)" -gt 0 ]; then
        echo -e "${GREEN}✓ Build-Tools $BUILD_TOOLS_VERSION 已经安装${NC}"
        echo ""
        return 0
    fi
    
    echo -e "${YELLOW}[1/2] 下载 Build-Tools $BUILD_TOOLS_VERSION...${NC}"
    echo ""
    
    # macOS 的文件名（根据系统自动选择）
    local os_type="$(uname -s)"
    local build_tools_file=""
    
    if [ "$os_type" = "Darwin" ]; then
        build_tools_file="build-tools_r${BUILD_TOOLS_VERSION}-macosx.zip"
    elif [ "$os_type" = "Linux" ]; then
        build_tools_file="build-tools_r${BUILD_TOOLS_VERSION}-linux.zip"
    else
        echo -e "${RED}不支持的操作系统: $os_type${NC}"
        return 1
    fi
    
    local download_url="${MIRROR_BASE}/${build_tools_file}"
    
    echo "下载地址: $download_url"
    echo ""
    
    # 下载文件
    if command -v curl > /dev/null; then
        curl -L -o "$build_tools_file" "$download_url" --progress-bar
    elif command -v wget > /dev/null; then
        wget "$download_url" -O "$build_tools_file"
    else
        echo -e "${RED}错误: 需要 curl 或 wget 命令${NC}"
        return 1
    fi
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}下载失败！${NC}"
        echo ""
        echo "请尝试手动下载："
        echo "  1. 访问: $download_url"
        echo "  2. 下载后保存到: $TEMP_DIR/$build_tools_file"
        echo "  3. 重新运行此脚本"
        return 1
    fi
    
    echo -e "${GREEN}下载完成！${NC}"
    echo ""
    
    # 解压安装
    echo "正在安装到 $build_tools_dir..."
    mkdir -p "$build_tools_dir"
    
    # 解压（Build-Tools 包里通常有个子目录 android-*）
    unzip -q "$build_tools_file" -d "$TEMP_DIR/build-tools-extract"
    
    # 移动文件到正确位置
    if [ -d "$TEMP_DIR/build-tools-extract/android-"* ]; then
        mv "$TEMP_DIR/build-tools-extract/android-"*/* "$build_tools_dir/"
    else
        mv "$TEMP_DIR/build-tools-extract"/* "$build_tools_dir/"
    fi
    
    # 添加可执行权限
    chmod +x "$build_tools_dir"/*
    
    echo -e "${GREEN}✓ Build-Tools $BUILD_TOOLS_VERSION 安装完成！${NC}"
    echo ""
    
    # 清理
    rm -rf "$build_tools_file" "$TEMP_DIR/build-tools-extract"
}

# 下载 Platform 30
install_platform() {
    local platform_dir="$SDK_DIR/platforms/android-$PLATFORM_VERSION"
    
    if [ -d "$platform_dir" ] && [ -f "$platform_dir/android.jar" ]; then
        echo -e "${GREEN}✓ Platform android-$PLATFORM_VERSION 已经安装${NC}"
        echo ""
        return 0
    fi
    
    echo -e "${YELLOW}[2/2] 下载 Platform android-$PLATFORM_VERSION...${NC}"
    echo ""
    
    local platform_file="platform-${PLATFORM_VERSION}_r03.zip"
    local download_url="${MIRROR_BASE}/${platform_file}"
    
    echo "下载地址: $download_url"
    echo ""
    
    # 下载文件
    if command -v curl > /dev/null; then
        curl -L -o "$platform_file" "$download_url" --progress-bar
    elif command -v wget > /dev/null; then
        wget "$download_url" -O "$platform_file"
    else
        echo -e "${RED}错误: 需要 curl 或 wget 命令${NC}"
        return 1
    fi
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}下载失败！${NC}"
        echo ""
        echo "请尝试手动下载："
        echo "  1. 访问: $download_url"
        echo "  2. 下载后保存到: $TEMP_DIR/$platform_file"
        echo "  3. 重新运行此脚本"
        return 1
    fi
    
    echo -e "${GREEN}下载完成！${NC}"
    echo ""
    
    # 解压安装
    echo "正在安装到 $platform_dir..."
    mkdir -p "$platform_dir"
    unzip -q "$platform_file" -d "$platform_dir"
    
    echo -e "${GREEN}✓ Platform android-$PLATFORM_VERSION 安装完成！${NC}"
    echo ""
    
    # 清理
    rm -f "$platform_file"
}

# 验证安装
verify_installation() {
    echo -e "${YELLOW}验证安装...${NC}"
    echo ""
    
    local success=true
    
    # 检查 Build-Tools
    if [ -f "$SDK_DIR/build-tools/$BUILD_TOOLS_VERSION/aapt" ]; then
        echo -e "${GREEN}✓ Build-Tools $BUILD_TOOLS_VERSION: OK${NC}"
    else
        echo -e "${RED}✗ Build-Tools $BUILD_TOOLS_VERSION: 安装不完整${NC}"
        success=false
    fi
    
    # 检查 Platform
    if [ -f "$SDK_DIR/platforms/android-$PLATFORM_VERSION/android.jar" ]; then
        echo -e "${GREEN}✓ Platform android-$PLATFORM_VERSION: OK${NC}"
    else
        echo -e "${RED}✗ Platform android-$PLATFORM_VERSION: 安装不完整${NC}"
        success=false
    fi
    
    echo ""
    
    if $success; then
        echo -e "${GREEN}=========================================="
        echo "  所有组件安装成功！"
        echo "==========================================${NC}"
        echo ""
        echo "现在可以开始编译了："
        echo "  ./智能编译APK.sh"
        echo ""
        return 0
    else
        echo -e "${RED}=========================================="
        echo "  安装验证失败"
        echo "==========================================${NC}"
        return 1
    fi
}

# 清理函数
cleanup() {
    echo "清理临时文件..."
    cd /
    rm -rf "$TEMP_DIR"
}

# 设置退出时清理
trap cleanup EXIT

# 主函数
main() {
    echo "开始安装 Android SDK 组件..."
    echo "项目需要: Build-Tools $BUILD_TOOLS_VERSION 和 Platform android-$PLATFORM_VERSION"
    echo ""
    
    # 创建必要的目录
    mkdir -p "$SDK_DIR/build-tools"
    mkdir -p "$SDK_DIR/platforms"
    
    # 安装组件
    if install_build_tools && install_platform; then
        verify_installation
    else
        echo -e "${RED}安装过程出错${NC}"
        exit 1
    fi
}

# 运行主函数
main

