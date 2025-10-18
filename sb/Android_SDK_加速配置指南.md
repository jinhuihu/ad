# Android Studio SDK 下载加速配置指南

## 问题描述
Android Studio 下载 SDK、Gradle 等资源时速度很慢，主要原因是国内访问 Google 服务器受限。

## 解决方案

### ✅ 方案一：Gradle 依赖镜像配置（已完成）

已将 `build.gradle` 配置为使用阿里云镜像源，这会加速 Gradle 依赖和插件的下载。

### 📝 方案二：配置 Android SDK Manager 镜像

#### 步骤 1：在 Android Studio 中配置 HTTP 代理

1. 打开 Android Studio
2. 进入 `File` → `Settings`（Mac 上是 `Android Studio` → `Preferences`）
3. 搜索 `HTTP Proxy`
4. 选择 `No proxy` 或配置您的代理

#### 步骤 2：使用国内镜像服务器

**方法 A：修改 hosts 文件（临时方案，不推荐）**

编辑系统 hosts 文件：
- Mac/Linux: `/etc/hosts`
- Windows: `C:\Windows\System32\drivers\etc\hosts`

添加以下内容：
```
# 注意：这些 IP 地址可能会变化，需要查找最新的
203.208.40.66 dl.google.com
203.208.40.66 dl-ssl.google.com
```

**方法 B：使用国内 SDK 镜像源（推荐）**

配置 Android SDK Manager 使用国内镜像：

1. 关闭 Android Studio
2. 编辑或创建文件：`~/.android/repositories.cfg` (Mac/Linux) 或 `C:\Users\<用户名>\.android\repositories.cfg` (Windows)
3. 添加以下内容：

```properties
# 阿里云镜像
repo.google.com=maven.aliyun.com/repository/google
dl.google.com=maven.aliyun.com/repository/google
```

### 📥 方案三：手动下载 SDK

如果以上方法仍然很慢，可以手动下载 SDK：

#### 1. 从国内镜像站下载

**推荐的国内镜像站：**
- 阿里云镜像：https://developer.aliyun.com/mirror/android
- 腾讯 Bugly SDK：https://bugly.qq.com/docs/
- 清华大学开源镜像：https://mirrors.tuna.tsinghua.edu.cn/help/AOSP/

#### 2. 手动安装步骤

1. 确定需要的 SDK 版本（查看项目的 `build.gradle` 文件）
   - 当前项目需要：`compileSdkVersion 30`
   - Build Tools: `30.0.3`

2. 下载对应的 SDK 包

3. 解压到 SDK 目录：`/Users/hujinhui/Library/Android/sdk`

4. 目录结构应该类似：
   ```
   sdk/
   ├── platforms/
   │   └── android-30/
   ├── build-tools/
   │   └── 30.0.3/
   ├── platform-tools/
   └── tools/
   ```

### 🔧 方案四：配置 Gradle 代理（如果您有代理）

编辑或创建文件：`~/.gradle/gradle.properties`

添加以下内容：
```properties
# HTTP 代理配置
systemProp.http.proxyHost=代理服务器地址
systemProp.http.proxyPort=代理端口
systemProp.http.nonProxyHosts=*.aliyun.com|localhost

# HTTPS 代理配置
systemProp.https.proxyHost=代理服务器地址
systemProp.https.proxyPort=代理端口
systemProp.https.nonProxyHosts=*.aliyun.com|localhost
```

### 🚀 方案五：使用 Gradle Wrapper 本地缓存

如果 Gradle Wrapper 下载很慢，可以：

1. 手动下载 Gradle 发行版：https://services.gradle.org/distributions/
2. 下载后放到：`~/.gradle/wrapper/dists/` 目录
3. 或者修改 `gradle/wrapper/gradle-wrapper.properties`，使用国内镜像：

```properties
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
# 使用腾讯云镜像
distributionUrl=https://mirrors.cloud.tencent.com/gradle/gradle-7.5-bin.zip
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
```

## 常用国内镜像源汇总

### Maven 仓库镜像

#### 阿里云（推荐）
```gradle
maven { url 'https://maven.aliyun.com/repository/google' }
maven { url 'https://maven.aliyun.com/repository/public' }
maven { url 'https://maven.aliyun.com/repository/jcenter' }
maven { url 'https://maven.aliyun.com/repository/gradle-plugin' }
```

#### 腾讯云
```gradle
maven { url 'https://mirrors.cloud.tencent.com/nexus/repository/maven-public/' }
```

#### 华为云
```gradle
maven { url 'https://repo.huaweicloud.com/repository/maven/' }
```

### Gradle 发行版镜像

- 腾讯云：https://mirrors.cloud.tencent.com/gradle/
- 阿里云：https://mirrors.aliyun.com/macports/distfiles/gradle/
- 华为云：https://repo.huaweicloud.com/gradle/

## 验证配置

### 1. 清理并重新构建项目

```bash
# 在项目根目录执行
./gradlew clean
./gradlew build
```

### 2. 查看下载速度

观察 Android Studio 底部的进度条或终端输出，应该能看到明显的速度提升。

### 3. 检查依赖来源

在构建日志中查看是否从国内镜像下载依赖。

## 故障排查

### 问题 1：仍然很慢
- 确认网络连接正常
- 尝试更换其他镜像源
- 检查是否有防火墙或安全软件阻拦

### 问题 2：构建失败
- 检查镜像源 URL 是否正确
- 确认镜像源是否正常运行
- 尝试注释掉镜像配置，使用原始源

### 问题 3：找不到某些依赖
- 国内镜像可能不完整
- 将原始源（`google()`、`mavenCentral()`）放在镜像源之后作为备用

## 推荐配置（平衡速度和完整性）

```gradle
repositories {
    // 优先使用国内镜像（速度快）
    maven { url 'https://maven.aliyun.com/repository/google' }
    maven { url 'https://maven.aliyun.com/repository/public' }
    
    // 备用官方源（保证完整性）
    google()
    mavenCentral()
}
```

## 额外优化建议

1. **启用 Gradle 离线模式**（如果依赖已下载）
   - `File` → `Settings` → `Build, Execution, Deployment` → `Gradle`
   - 勾选 `Offline work`

2. **增加 Gradle 堆内存**
   编辑 `gradle.properties`：
   ```properties
   org.gradle.jvmargs=-Xmx4096m -XX:MaxPermSize=512m
   org.gradle.parallel=true
   org.gradle.caching=true
   ```

3. **使用 Gradle 构建缓存**
   ```properties
   org.gradle.caching=true
   ```

## 参考链接

- 阿里云 Maven 仓库：https://developer.aliyun.com/mvn/guide
- Android 开发者官网：https://developer.android.com/
- Gradle 官方文档：https://docs.gradle.org/

---

**注意事项：**
- 镜像源的可用性和速度可能会变化
- 建议保留官方源作为备用
- 定期检查镜像源是否正常工作
- 如果使用公司网络，请遵守公司的网络安全政策

