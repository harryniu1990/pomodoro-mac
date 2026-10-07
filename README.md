# 🍅 Pomodoro — macOS 悬浮番茄钟

一个轻量的 macOS 桌面番茄钟小工具：平时缩成屏幕角落的迷你悬浮条，计时结束才弹出确认，不打断你的工作流。

## 特性

- **悬浮迷你条** — 计时中缩成一条小胶囊置顶显示（所有空间可见），可拖到任意位置
- **到点才打扰** — 专注/休息结束时窗口自动弹出，弹确认卡片：开始休息 / 跳过休息，点了才走
- **番茄工作法循环** — 可配置「每 N 个番茄进入长休息」，圆点显示本轮进度
- **统计** — 今日番茄数、今日专注分钟数、累计番茄数，本地保存
- **主题自定义** — 5 套预设配色 + 三模式独立取色器
- **提示音 & 通知** — 完成时和弦琶音提示（网页版另有桌面通知）
- **快捷键** — 空格键开始/暂停

## 截图

<p align="center">
  <img src="assets/icon_1024.png" width="128" alt="Pomodoro icon">
</p>

## 安装

**方式一：下载安装包**（推荐）

👉 [Releases 页面](https://github.com/harryniu1990/pomodoro-mac/releases/latest) 下载最新版 DMG（含自动安装脚本）。

- 通用二进制：Apple Silicon (M 系列) + Intel 原生支持
- 系统要求：macOS 11.0+
- 安装包内附 `安装.command`，双击即可自动安装并清除系统隔离标记

**方式二：自己构建**（干净放心，无安全提示）

```bash
git clone https://github.com/harryniu1990/pomodoro-mac.git
cd pomodoro-mac
./build.sh
open Pomodoro.app
```

依赖：Xcode Command Line Tools（`xcode-select --install`）。
图标生成需要 Python + Pillow（可选，没有也能正常用）。

## 关于安全提示（分发给他人时必看）

应用未购买苹果开发者证书，macOS Gatekeeper 会拦截。**按以下顺序解决**（详见安装包内 `安装说明.txt`）：

1. **系统设置 → 隐私与安全性 → 下滑到「安全性」→ 点「仍要打开」** ← 最有效
2. 访达中右键 `Pomodoro.app` → 打开 → 弹窗点「打开」
3. 终端执行：`sudo xattr -rd com.apple.quarantine /Applications/Pomodoro.app`

⚠️ 注意：`xattr -cr` 必须作用在 `/Applications` 里的那份副本，且要在**复制完成后**执行；
如果是对下载目录里的 `.app` 执行的，或执行时路径写错，就会仍然报错。

**彻底解决方案**：用 Apple 开发者账号签名并公证（需付费账号）；
在此之前，`./build.sh` 已自动对产物做 ad-hoc 签名，能消除「应用已损坏」类报错。

## 技术架构

| 文件 | 说明 |
|---|---|
| `src/index.html` | 单文件前端：计时逻辑、迷你条、确认卡片、主题系统（无任何依赖） |
| `src/main.swift` | 原生外壳：无边框置顶悬浮窗（WKWebView），窗口大小切换、拖拽、焦点控制 |
| `build.sh` | 一键构建脚本：swiftc 编译 → 打包 .app → 生成 icns 图标 |

前后端通过 `WKScriptMessageHandler` 通信：JS 发送 `mini / full / done / quit / move` 消息，Swift 响应窗口动画、焦点抢夺和位移。

## 使用

- **缩小**：完整界面右上角 `—`，缩成悬浮条
- **展开**：点悬浮条上的时间或 `⤢`
- **拖动**：按住任意非按钮区域拖动（两种形态都支持）
- **移动窗口到全屏之上**：窗口级别为 floating，切到任何桌面都能看到
- **退出**：完整界面左上角 `×` 或 `⌘Q`（不占 Dock）

## License

MIT
