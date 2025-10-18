#!/bin/bash
# 快速编译 APK - 使用 Gradle 自动下载 SDK 组件
# Gradle 会使用已配置的阿里云镜像，速度会快很多

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=========================================="
echo "  快速编译 Android APK"
echo "==========================================${NC}"
echo ""

# 检查目录
if [ ! -d "AndroidCaptchaSolver" ]; then
    echo -e "${RED}错误: 请在项目根目录运行此脚本${NC}"
    exit 1
fi

cd AndroidCaptchaSolver

echo -e "${GREEN}提示：${NC}已配置阿里云镜像加速，下载速度会快很多"
echo ""

# 设置 Gradle 环境变量
export GRADLE_OPTS="-Xmx4096m -XX:MaxPermSize=512m"
export ANDROID_SDK_ROOT="/Users/hujinhui/Library/Android/sdk"

# 显示 Gradle 版本
echo -e "${YELLOW}检查 Gradle...${NC}"
./gradlew --version
echo ""

# 清理项目
echo -e "${YELLOW}[1/2] 清理项目...${NC}"
./gradlew clean

echo ""

# 编译 APK
echo -e "${YELLOW}[2/2] 编译 APK...${NC}"
echo ""
echo -e "${BLUE}开始编译，首次编译会下载依赖，请耐心等待...${NC}"
echo -e "${BLUE}如果下载 SDK 组件，会从阿里云镜像下载，速度较快${NC}"
echo ""

# 编译，显示详细日志
./gradlew assembleDebug --info --stacktrace 2>&1 | tee build.log

BUILD_RESULT=${PIPESTATUS[0]}

echo ""

if [ $BUILD_RESULT -eq 0 ]; then
    echo -e "${GREEN}=========================================="
    echo "  ✓ 编译成功！"
    echo "==========================================${NC}"
    echo ""
    
    # 查找 APK
    APK_FILE=$(find app/build/outputs/apk/debug -name "*.apk" 2>/dev/null | head -1)
    
    if [ -z "$APK_FILE" ]; then
        APK_FILE=$(find . -name "app-debug.apk" 2>/dev/null | head -1)
    fi
    
    if [ -n "$APK_FILE" ]; then
        APK_SIZE=$(du -h "$APK_FILE" | cut -f1)
        APK_FULL_PATH="$(cd "$(dirname "$APK_FILE")" && pwd)/$(basename "$APK_FILE")"
        
        echo "  📱 APK 文件: $(basename "$APK_FILE")"
        echo "  📦 文件大小: $APK_SIZE"
        echo "  📍 完整路径: $APK_FULL_PATH"
        echo ""
        
        # 复制到项目根目录
        cp "$APK_FILE" "../app-debug.apk"
        echo -e "${GREEN}  ✓ 已复制到: $(pwd)/../app-debug.apk${NC}"
        echo ""
        
        # 询问是否安装
        read -p "是否要安装到连接的 Android 设备? (y/n): " choice
        
        if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
            echo ""
            echo "检查设备..."
            adb devices
            echo ""
            
            device_count=$(adb devices | grep -v "List" | grep "device$" | wc -l | tr -d ' ')
            
            if [ "$device_count" -gt 0 ]; then
                echo "安装 APK..."
                adb install -r "$APK_FULL_PATH"
                
                if [ $? -eq 0 ]; then
                    echo ""
                    echo -e "${GREEN}✓ 安装成功！${NC}"
                    echo ""
                    echo "📋 使用步骤："
                    echo "  1. 打开手机上的 '验证码识别助手'"
                    echo "  2. 点击 '启动服务'"
                    echo "  3. 启用无障碍服务权限"
                    echo "  4. 测试验证码识别功能"
                fi
            else
                echo -e "${YELLOW}未检测到连接的设备${NC}"
                echo "请连接 Android 设备并启用 USB 调试"
            fi
        fi
    fi
else
    echo -e "${RED}=========================================="
    echo "  ✗ 编译失败"
    echo "==========================================${NC}"
    echo ""
    echo "查看最后 30 行错误日志："
    echo ""
    tail -30 build.log
    echo ""
    echo "完整日志: $(pwd)/build.log"
    echo ""
    
    # 分析常见错误
    if grep -q "SDK Build-Tools" build.log; then
        echo -e "${YELLOW}可能的问题: SDK Build-Tools 下载${NC}"
        echo "解决方案："
        echo "  1. Gradle 会自动下载，多等待一会"
        echo "  2. 检查网络连接"
        echo "  3. 重新运行此脚本"
    fi
    
    if grep -q "platforms;android-30" build.log; then
        echo -e "${YELLOW}可能的问题: Android Platform 30 下载${NC}"
        echo "解决方案："
        echo "  1. Gradle 会自动下载，多等待一会"
        echo "  2. 检查网络连接"
        echo "  3. 重新运行此脚本"
    fi
    
    exit 1
fi

