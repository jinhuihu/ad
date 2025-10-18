# Android SDK 修复指南

## 问题描述
android-36 平台的 `android.jar` 文件损坏，导致编译失败。

错误信息：
```
Failed to load resources table in APK '/Users/hujinhui/Library/Android/sdk/platforms/android-36/android.jar'
```

## 解决方案

### 方案一：使用 Android Studio SDK Manager（推荐⭐）

1. 打开 Android Studio
2. 点击菜单栏：**Tools** → **SDK Manager**
3. 在 **SDK Platforms** 标签页：
   - 找到 **Android API 36**
   - 取消勾选
   - 点击 **Apply** 按钮卸载
   - 重新勾选 **Android API 36**
   - 点击 **Apply** 按钮重新下载

**优点：**
- 自动使用镜像加速
- 可靠且不易出错
- 可以同时下载其他需要的组件

### 方案二：命令行手动下载

#### 步骤 1：备份并删除损坏的 SDK
```bash
cd /Users/hujinhui/Library/Android/sdk/platforms
mv android-36 android-36.backup
```

#### 步骤 2：下载正确的 SDK 平台
```bash
# 使用代理下载（如果有）
curl -L -x http://127.0.0.1:9000 -o /tmp/platform-36.1.zip \
  "https://dl.google.com/android/repository/platform-36.1_r01.zip" \
  --max-time 1800

# 或不使用代理
curl -L -o /tmp/platform-36.1.zip \
  "https://dl.google.com/android/repository/platform-36.1_r01.zip" \
  --max-time 1800
```

#### 步骤 3：解压并安装
```bash
cd /Users/hujinhui/Library/Android/sdk/platforms
unzip /tmp/platform-36.1.zip -d ./
mv android-15 android-36  # Google 的 SDK zip 内部目录名可能不同
```

#### 步骤 4：验证安装
```bash
ls -lh /Users/hujinhui/Library/Android/sdk/platforms/android-36/android.jar
```

### 方案三：临时降级使用 SDK 33

如果急需编译，可以临时使用 SDK 33：

#### 步骤 1：下载 SDK 33 平台
使用 Android Studio SDK Manager 下载 **Android API 33**

#### 步骤 2：修改项目配置
编辑 `AndroidCaptchaSolver/app/build.gradle`：
```gradle
android {
    compileSdkVersion 33
    buildToolsVersion "33.0.0"

    defaultConfig {
        applicationId "com.captchasolver"
        minSdkVersion 21
        targetSdkVersion 33
        // ...
    }
}
```

#### 步骤 3：清理并编译
```bash
cd /Users/hujinhui/project/sb
bash 快速编译.sh
```

## 当前状态

✅ 已检测到问题：android-36 的 android.jar 损坏  
🔄 后台下载任务已启动（预计 30 分钟）  
📝 推荐使用 Android Studio SDK Manager 修复

## 编译 APK

修复 SDK 后，使用以下命令编译：

```bash
cd /Users/hujinhui/project/sb
bash 快速编译.sh
```

或手动编译：

```bash
cd /Users/hujinhui/project/sb/AndroidCaptchaSolver
export ANDROID_HOME=/Users/hujinhui/Library/Android/sdk
./gradlew clean
./gradlew assembleDebug
```

编译成功后，APK 文件位置：
```
AndroidCaptchaSolver/app/build/outputs/apk/debug/app-debug.apk
```

## 相关文件

- SDK 路径：`/Users/hujinhui/Library/Android/sdk`
- Build Tools：`/Users/hujinhui/Library/Android/sdk/build-tools/`
- Platforms：`/Users/hujinhui/Library/Android/sdk/platforms/`
- 项目配置：`AndroidCaptchaSolver/app/build.gradle`

