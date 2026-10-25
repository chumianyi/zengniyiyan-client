# 赠你一言

一款简约的一言（古诗词）Flutter 客户端，采用 **Neumorphism（新拟态）** 设计主题，最低支持 **Android 7.0（API 24）**。

## 下载安装

前往 [Releases](https://github.com/chumianyi/zengniyiyan-client/releases) 页面下载最新的 `zengniyiyan-1.0.0-release.apk`（约 50MB，四架构通用包，含 v2/v3 签名，安卓 7.0+ 可直接安装）。

## 功能特性

- **一言卡片**：衬线排版展示随机古诗词一言及出处，标注「第 x / 总条数」
- **一键刷新**：点击下方琥珀色刷新按钮即获取新的一言，旋转动画 + 平滑过渡
- **复制 / 分享**：一键复制到剪贴板，或通过系统分享面板发送给朋友
- **深浅双主题**：亮色 `#E0E5EC` / 暗色 `#2B2F36` 新拟态双配色，一键切换并记忆
- **细节体验**：加载态、错误态与重试提示、SnackBar 轻提示、长文本自适应滚动

## 数据来源

一言 API：`http://xingheios.us.ci/api/yiyan`

## 技术栈

| 项 | 说明 |
|---|---|
| 框架 | Flutter 3.24.5（Dart） |
| 主题 | 自绘 Neumorphism 组件库（`lib/neu.dart`） |
| 网络 | `http` 包，直连一言 API |
| 存储 | `shared_preferences`（主题记忆） |
| 原生交互 | Kotlin MethodChannel（系统分享） |
| 构建 | GitHub Actions（Flutter 3.24.5 + AGP 8.3.0 + Gradle 8.4 + JDK 17） |

## 构建

推送代码到 `main` 分支或打 `v*` 标签会自动触发 GitHub Actions 构建；也可在 Actions 页面手动 `Run workflow`。CI 会现场生成签名密钥库并产出可安装的 Release APK，同时上传为 90 天有效期的构建产物。

本地构建（可选）：

```bash
flutter pub get
flutter build apk --release
```

## 项目结构

```
lib/
├── main.dart            # 应用入口、主题管理
├── home_screen.dart     # 主页面（一言卡片 + 操作按钮）
├── neu.dart             # Neumorphism 主题与组件库
└── yiyan_service.dart   # 一言 API 服务
android/                 # Android 宿主工程（minSdk 24 / targetSdk 34）
.github/workflows/       # GitHub Actions 构建流水线
```

## 声明

本应用为个人学习作品，一言数据来自第三方公开 API，版权归原 API 方所有。
