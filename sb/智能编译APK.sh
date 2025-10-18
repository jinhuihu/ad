#!/bin/bash
# 智能编译 APK 脚本
# 自动检查并处理 SDK 组件问题
# 优化编译速度

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=========================================="
echo "  Android 验证码识别助手 - 智能编译"
echo "==========================================${NC}"
echo ""

# 检查是否在正确的目录
if [ ! -f "AndroidCaptchaSolver/build.gradle" ]; then
    echo -e "${RED}错误: 请在项目根目录运行此脚本${NC}"
    exit 1
fi

# SDK 配置
SDK_DIR="/Users/hujinhui/Library/Android/sdk"
BUILD_TOOLS_VERSION="30.0.3"
BUILD_TOOLS_DIR="$SDK_DIR/build-tools/$BUILD_TOOLS_VERSION"
PLATFORM_DIR="$SDK_DIR/platforms/android-30"

# 步骤1：检查 SDK 组件
check_sdk_components() {
    echo -e "${YELLOW}[1/5] 检查 SDK 组件...${NC}"
    echo ""
    
    local missing_components=()
    
    # 检查 Build-Tools
    if [ ! -d "$BUILD_TOOLS_DIR" ]; then
        echo -e "${RED}✗ Build-Tools 30.0.3 未安装${NC}"
        missing_components+=("build-tools")
    else
        echo -e "${GREEN}✓ Build-Tools 30.0.3 已安装${NC}"
    fi
    
    # 检查 Platform
    if [ ! -d "$PLATFORM_DIR" ]; then
        echo -e "${RED}✗ Android SDK Platform 30 未安装${NC}"
        missing_components+=("platform")
    else
        echo -e "${GREEN}✓ Android SDK Platform 30 已安装${NC}"
    fi
    
    echo ""
    
    # 如果有缺失组件，提供解决方案
    if [ ${#missing_components[@]} -gt 0 ]; then
        echo -e "${YELLOW}检测到缺失的 SDK 组件！${NC}"
        echo ""
        echo "请选择解决方案："
        echo "  1. 使用 sdkmanager 自动安装（可能会慢）"
        echo "  2. 查看手动下载指引"
        echo "  3. 跳过检查，尝试编译（Gradle 会自动下载）"
        echo "  4. 退出脚本"
        echo ""
        read -p "请选择 [1-4]: " choice
        
        case $choice in
            1)
                install_sdk_components
                ;;
            2)
                show_manual_guide
                exit 0
                ;;
            3)
                echo -e "${YELLOW}跳过检查，继续编译...${NC}"
                echo ""
                ;;
            4)
                echo "退出脚本"
                exit 0
                ;;
            *)
                echo -e "${RED}无效选择，退出${NC}"
                exit 1
                ;;
        esac
    fi
}

# 安装 SDK 组件
install_sdk_components() {
    echo -e "${YELLOW}尝试自动安装 SDK 组件...${NC}"
    echo ""
    
    SDKMANAGER="$SDK_DIR/cmdline-tools/latest/bin/sdkmanager"
    
    if [ ! -f "$SDKMANAGER" ]; then
        SDKMANAGER="$SDK_DIR/tools/bin/sdkmanager"
    fi
    
    if [ -f "$SDKMANAGER" ]; then
        echo "使用 sdkmanager 安装..."
        yes | "$SDKMANAGER" "build-tools;30.0.3" "platforms;android-30" --sdk_root="$SDK_DIR" || true
        echo ""
    else
        echo -e "${YELLOW}未找到 sdkmanager，请查看手动安装指引${NC}"
        show_manual_guide
        exit 1
    fi
}

# 显示手动安装指引
show_manual_guide() {
    echo -e "${BLUE}=========================================="
    echo "  手动下载 SDK 组件指引"
    echo "==========================================${NC}"
    echo ""
    echo "由于 Google 服务器在国内访问很慢，建议从国内镜像下载："
    echo ""
    echo -e "${GREEN}清华大学开源镜像（推荐）：${NC}"
    echo "https://mirrors.tuna.tsinghua.edu.cn/android/repository/"
    echo ""
    echo "需要下载的文件："
    echo "  1. build-tools_r30.0.3-macosx.zip"
    echo "  2. platform-30_r03.zip"
    echo ""
    echo "下载后解压到对应目录："
    echo "  mkdir -p \"$SDK_DIR/build-tools/30.0.3\""
    echo "  unzip build-tools_r30.0.3-macosx.zip -d \"$SDK_DIR/build-tools/30.0.3\""
    echo ""
    echo "  mkdir -p \"$SDK_DIR/platforms/android-30\""
    echo "  unzip platform-30_r03.zip -d \"$SDK_DIR/platforms/android-30\""
    echo ""
    echo "或者运行辅助脚本："
    echo "  ./下载BuildTools.sh"
    echo ""
}

# 步骤2：配置 Gradle
configure_gradle() {
    echo -e "${YELLOW}[2/5] 配置 Gradle...${NC}"
    
    # 设置 Gradle 选项以加速编译
    export GRADLE_OPTS="-Xmx4096m -XX:MaxPermSize=512m -XX:+HeapDumpOnOutOfMemoryError"
    
    # 设置离线模式（如果组件都在本地）
    # export GRADLE_OFFLINE="--offline"
    
    echo -e "${GREEN}✓ Gradle 配置完成${NC}"
    echo ""
}

# 步骤3：清理项目
clean_project() {
    echo -e "${YELLOW}[3/5] 清理项目...${NC}"
    cd AndroidCaptchaSolver
    
    # 使用 --info 可以看到更详细的日志
    ./gradlew clean --warning-mode all
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ 清理完成${NC}"
    else
        echo -e "${YELLOW}⚠ 清理过程有警告，继续编译...${NC}"
    fi
    echo ""
}

# 步骤4：编译 Debug 版本
build_debug() {
    echo -e "${YELLOW}[4/5] 编译 Debug APK...${NC}"
    echo ""
    echo -e "${BLUE}这可能需要几分钟，请耐心等待...${NC}"
    echo ""
    
    # 使用 --info 查看详细信息，--stacktrace 查看错误堆栈
    ./gradlew assembleDebug --stacktrace --info > build.log 2>&1 &
    
    # 获取后台进程 PID
    BUILD_PID=$!
    
    # 显示进度动画
    show_progress $BUILD_PID
    
    # 等待编译完成
    wait $BUILD_PID
    BUILD_RESULT=$?
    
    echo ""
    
    if [ $BUILD_RESULT -eq 0 ]; then
        echo -e "${GREEN}✓ 编译成功！${NC}"
        return 0
    else
        echo -e "${RED}✗ 编译失败${NC}"
        echo ""
        echo "查看最后 50 行日志："
        tail -50 build.log
        echo ""
        echo "完整日志保存在: AndroidCaptchaSolver/build.log"
        echo ""
        
        # 检查是否是 SDK 下载问题
        if grep -q "Could not resolve all dependencies" build.log || \
           grep -q "Could not download" build.log || \
           grep -q "Connection timed out" build.log; then
            echo -e "${YELLOW}检测到下载问题，可能的原因：${NC}"
            echo "  1. SDK 组件下载失败"
            echo "  2. 网络连接问题"
            echo "  3. 镜像源配置未生效"
            echo ""
            echo "建议解决方案："
            echo "  1. 运行: ./配置Android镜像.sh"
            echo "  2. 查看: Android_SDK_加速配置指南.md"
            echo "  3. 手动下载 SDK 组件（参考上面的指引）"
        fi
        
        return 1
    fi
}

# 显示进度动画
show_progress() {
    local pid=$1
    local spin='-\|/'
    local i=0
    
    while kill -0 $pid 2>/dev/null; do
        i=$(( (i+1) %4 ))
        printf "\r${BLUE}编译中 ${spin:$i:1} ${NC}"
        sleep 0.2
        
        # 每隔几秒显示日志片段
        if [ $(( i % 20 )) -eq 0 ]; then
            if [ -f build.log ]; then
                local last_line=$(tail -1 build.log | grep -o "Task.*" || echo "")
                if [ -n "$last_line" ]; then
                    printf "\r${BLUE}编译中... $last_line${NC}\033[K\n"
                fi
            fi
        fi
    done
    
    printf "\r\033[K"  # 清除进度行
}

# 步骤5：处理编译结果
handle_result() {
    echo -e "${YELLOW}[5/5] 处理编译结果...${NC}"
    
    # 查找生成的 APK 文件
    APK_FILE=$(find app/build/outputs/apk/debug -name "*.apk" 2>/dev/null | head -1)
    
    if [ -z "$APK_FILE" ]; then
        APK_FILE=$(find . -name "app-debug.apk" 2>/dev/null | head -1)
    fi
    
    if [ -n "$APK_FILE" ]; then
        # 获取 APK 信息
        APK_SIZE=$(du -h "$APK_FILE" | cut -f1)
        APK_FULL_PATH=$(cd "$(dirname "$APK_FILE")" && pwd)/$(basename "$APK_FILE")
        
        echo -e "${GREEN}✓ APK 生成成功！${NC}"
        echo ""
        echo "  📱 文件: $(basename "$APK_FILE")"
        echo "  📦 大小: $APK_SIZE"
        echo "  📍 位置: $APK_FULL_PATH"
        echo ""
        
        # 复制到项目根目录方便访问
        cp "$APK_FILE" "../app-debug.apk"
        echo -e "${GREEN}✓ APK 已复制到项目根目录: app-debug.apk${NC}"
        echo ""
        
        # 询问是否安装
        echo "接下来要做什么？"
        echo "  1. 安装到已连接的设备"
        echo "  2. 仅查看设备列表"
        echo "  3. 完成（不安装）"
        echo ""
        read -p "请选择 [1-3]: " install_choice
        
        case $install_choice in
            1)
                install_to_device "$APK_FULL_PATH"
                ;;
            2)
                echo ""
                adb devices -l
                ;;
            3)
                echo "编译完成！"
                ;;
        esac
    else
        echo -e "${RED}✗ 未找到生成的 APK 文件${NC}"
        echo "请检查编译日志: AndroidCaptchaSolver/build.log"
        return 1
    fi
}

# 安装到设备
install_to_device() {
    local apk_file=$1
    
    echo ""
    echo "检查连接的设备..."
    adb devices
    echo ""
    
    # 检查是否有设备连接
    device_count=$(adb devices | grep -v "List" | grep "device$" | wc -l | tr -d ' ')
    
    if [ "$device_count" -eq 0 ]; then
        echo -e "${YELLOW}未检测到连接的设备${NC}"
        echo "请连接 Android 设备并启用 USB 调试"
        return 1
    fi
    
    echo "安装 APK 到设备..."
    adb install -r "$apk_file"
    
    if [ $? -eq 0 ]; then
        echo ""
        echo -e "${GREEN}✓ 安装成功！${NC}"
        echo ""
        echo "📋 使用步骤："
        echo "  1. 在手机上打开 '验证码识别助手' 应用"
        echo "  2. 点击 '启动服务' 按钮"
        echo "  3. 在设置中启用无障碍服务权限"
        echo "  4. 打开浏览器测试验证码识别功能"
        echo ""
        echo "📖 详细说明: 使用指南.md"
    else
        echo ""
        echo -e "${RED}✗ 安装失败${NC}"
        echo "可能的原因："
        echo "  - 设备未授权"
        echo "  - USB 调试未启用"
        echo "  - 存储空间不足"
    fi
}

# 主函数
main() {
    local start_time=$(date +%s)
    
    # 执行编译流程
    check_sdk_components
    configure_gradle
    clean_project
    
    if build_debug; then
        handle_result
        
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        
        echo ""
        echo -e "${GREEN}=========================================="
        echo "  编译流程完成！"
        echo "  总耗时: ${duration}秒"
        echo "==========================================${NC}"
    else
        echo ""
        echo -e "${RED}=========================================="
        echo "  编译失败"
        echo "==========================================${NC}"
        exit 1
    fi
}

# 运行主函数
main

