# FFmpeg视频转换工具

一个基于Flutter开发的简单易用的视频格式转换工具，专为Windows平台设计，内置FFmpeg支持。

## 功能特点

- 🎬 支持多种视频格式转换（MP4、AVI、MKV、MOV、FLV、WMV）
- 🖱️ 简洁直观的用户界面
- ⚡ 基于FFmpeg的高效转换
- 📁 自动保存到文档目录
- 🔧 内置FFmpeg支持，无需手动配置
- 📖 智能引导弹窗，帮助用户配置FFmpeg

## 系统要求

- Windows 10/11
- FFmpeg（软件会自动检测并提供配置指南）

## FFmpeg配置方式

软件提供两种FFmpeg配置方式：

### 方式一：内置FFmpeg（推荐）

1. 下载FFmpeg：https://ffmpeg.org/download.html
2. 解压FFmpeg到软件根目录，目录结构如下：
```
FFmpegUI/
├── ffmpeg/
│   └── bin/
│       ├── ffmpeg.exe
│       ├── ffplay.exe
│       └── ffprobe.exe
├── ffmpeg_ui.exe
└── ...
```
3. 重启软件即可使用

### 方式二：系统PATH配置

软件首次启动时会自动检测FFmpeg，如未检测到会弹出详细的配置指南，包括：
- FFmpeg下载链接
- 环境变量配置步骤
- 图文并茂的操作说明

## 开发环境配置

### 前置要求

- Flutter SDK (>=3.0.0)
- Visual Studio 2022（包含C++桌面开发工具）

### 安装步骤

1. 克隆项目
```bash
git clone <repository-url>
cd FFmpegUI
```

2. 安装依赖
```bash
flutter pub get
```

3. 运行项目
```bash
flutter run -d windows
```

## 构建发布版本

```bash
flutter build windows --release
```

构建完成后，可执行文件位于 `build\windows\x64\runner\Release\`

## 使用说明

1. 启动软件后，会自动检测FFmpeg
2. 如未检测到FFmpeg，会弹出配置指南
3. 配置完成后，点击"选择视频文件"按钮
4. 在下拉菜单中选择目标格式
5. 点击"开始转换"按钮
6. 等待转换完成，文件保存在文档目录

## 项目结构

```
FFmpegUI/
├── lib/
│   ├── main.dart                    # 应用入口
│   ├── screens/
│   │   └── home_screen.dart         # 主界面
│   ├── services/
│   │   └── ffmpeg_service.dart      # FFmpeg服务
│   └── widgets/
│       └── ffmpeg_guide_dialog.dart # 配置引导弹窗
├── windows/                          # Windows平台配置
├── pubspec.yaml                      # 项目依赖配置
└── README.md                         # 项目说明
```

## 依赖库

- `file_picker`: 文件选择器
- `path_provider`: 路径管理
- `process_run`: 进程执行
- `url_launcher`: URL启动器

## 许可证

MIT License

## 参考项目

本项目参考了 [FFmpegFreeUI](https://github.com/Lake1059/FFmpegFreeUI.git)
