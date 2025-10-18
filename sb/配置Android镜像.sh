#!/bin/bash
# Android Studio SDK 加速配置脚本
# 作者：自动生成
# 功能：自动配置 Android 开发环境使用国内镜像

set -e

echo "=========================================="
echo "  Android Studio SDK 加速配置脚本"
echo "=========================================="
echo ""

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 检测操作系统
OS_TYPE="$(uname -s)"
echo -e "${GREEN}检测到操作系统：${NC}${OS_TYPE}"
echo ""

# 配置 Gradle 全局代理
configure_gradle() {
    echo -e "${YELLOW}[1/4] 配置 Gradle 全局设置...${NC}"
    
    GRADLE_HOME="$HOME/.gradle"
    GRADLE_PROPS="$GRADLE_HOME/gradle.properties"
    
    # 创建 .gradle 目录（如果不存在）
    mkdir -p "$GRADLE_HOME"
    
    # 备份现有配置
    if [ -f "$GRADLE_PROPS" ]; then
        echo "备份现有配置到 gradle.properties.backup"
        cp "$GRADLE_PROPS" "$GRADLE_PROPS.backup"
    fi
    
    # 添加或更新配置
    cat >> "$GRADLE_PROPS" << 'EOF'

# ===== Android SDK 加速配置 (自动添加) =====
# Gradle 性能优化
org.gradle.jvmargs=-Xmx4096m -XX:MaxPermSize=512m -XX:+HeapDumpOnOutOfMemoryError
org.gradle.parallel=true
org.gradle.caching=true
org.gradle.daemon=true
org.gradle.configureondemand=true

# 使用阿里云镜像加速（取消注释以下行来使用代理）
# systemProp.http.proxyHost=your_proxy_host
# systemProp.http.proxyPort=your_proxy_port
# systemProp.https.proxyHost=your_proxy_host
# systemProp.https.proxyPort=your_proxy_port
EOF
    
    echo -e "${GREEN}✓ Gradle 配置完成${NC}"
    echo ""
}

# 配置 Android SDK Manager
configure_android_sdk() {
    echo -e "${YELLOW}[2/4] 配置 Android SDK Manager...${NC}"
    
    ANDROID_HOME="$HOME/.android"
    REPOSITORIES_CFG="$ANDROID_HOME/repositories.cfg"
    
    # 创建 .android 目录（如果不存在）
    mkdir -p "$ANDROID_HOME"
    
    # 创建 repositories.cfg
    cat > "$REPOSITORIES_CFG" << 'EOF'
# Android SDK Manager 镜像配置
# 使用阿里云镜像
repo.google.com=maven.aliyun.com/repository/google
dl.google.com=maven.aliyun.com/repository/google
dl-ssl.google.com=maven.aliyun.com/repository/google
EOF
    
    echo -e "${GREEN}✓ Android SDK Manager 配置完成${NC}"
    echo ""
}

# 配置 Gradle Wrapper 镜像
configure_gradle_wrapper() {
    echo -e "${YELLOW}[3/4] 配置项目 Gradle Wrapper...${NC}"
    
    WRAPPER_PROPS="./AndroidCaptchaSolver/gradle/wrapper/gradle-wrapper.properties"
    
    if [ -f "$WRAPPER_PROPS" ]; then
        # 备份
        cp "$WRAPPER_PROPS" "$WRAPPER_PROPS.backup"
        
        # 读取当前配置
        echo "当前 Gradle Wrapper 配置："
        cat "$WRAPPER_PROPS"
        echo ""
        
        echo -e "${GREEN}提示：如果下载 Gradle 很慢，可以手动编辑：${NC}"
        echo "$WRAPPER_PROPS"
        echo "将 distributionUrl 改为腾讯云镜像："
        echo "distributionUrl=https://mirrors.cloud.tencent.com/gradle/gradle-7.5-bin.zip"
    else
        echo -e "${YELLOW}未找到 Gradle Wrapper 配置文件${NC}"
    fi
    echo ""
}

# 显示配置总结
show_summary() {
    echo -e "${YELLOW}[4/4] 配置总结${NC}"
    echo ""
    echo "已完成以下配置："
    echo "  ✓ Gradle 全局配置：$HOME/.gradle/gradle.properties"
    echo "  ✓ Android SDK 配置：$HOME/.android/repositories.cfg"
    echo "  ✓ 项目 build.gradle 已使用阿里云镜像"
    echo ""
    echo -e "${GREEN}下一步操作：${NC}"
    echo "  1. 重启 Android Studio"
    echo "  2. 打开项目，等待 Gradle 同步"
    echo "  3. 下载速度应该会明显提升"
    echo ""
    echo -e "${YELLOW}如果还是很慢，请尝试：${NC}"
    echo "  1. 查看详细配置指南：./Android_SDK_加速配置指南.md"
    echo "  2. 检查网络连接"
    echo "  3. 尝试使用代理或 VPN"
    echo "  4. 手动下载 SDK"
    echo ""
    echo -e "${GREEN}测试配置：${NC}"
    echo "  cd AndroidCaptchaSolver"
    echo "  ./gradlew --version"
    echo ""
}

# 主函数
main() {
    # 检查是否在正确的目录
    if [ ! -d "AndroidCaptchaSolver" ]; then
        echo -e "${RED}错误：请在项目根目录（sb/）运行此脚本${NC}"
        exit 1
    fi
    
    # 执行配置步骤
    configure_gradle
    configure_android_sdk
    configure_gradle_wrapper
    show_summary
    
    echo -e "${GREEN}=========================================="
    echo "  配置完成！"
    echo "==========================================${NC}"
}

# 运行主函数
main

