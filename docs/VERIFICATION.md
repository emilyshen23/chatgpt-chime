# Verification / 验证情况

Checked on **October 27, 2026**, against the published **v1.1.0** download.

本次检查日期：**2026 年 10 月 27 日**；检查对象为已发布的 **v1.1.0** 安装包。

## Passed / 已通过

| Check / 检查项目 | Result / 结果 |
| --- | --- |
| GitHub build / GitHub 构建 | [v1.1.0 source build passed](https://github.com/emilyshen23/chatgpt-chime/actions/runs/40577912514). Tests, universal compilation, and packaging succeeded. / 测试、通用版本编译和打包均成功。 |
| Download / 下载文件 | Downloaded the published release again and verified its SHA-256 against the published checksum file. / 重新下载发布的安装包，SHA-256 与发布的校验文件一致。 |
| App signature / App 签名 | Extracted app passed `codesign --verify --strict`. This is an **ad hoc local signature**, not Apple Developer ID signing or notarization. / 解压后的 App 通过签名完整性检查；这是本地临时签名，不代表 Apple 开发者身份签名或 Apple 公证。 |
| Processor builds / 芯片支持 | Download contains both `arm64` and `x86_64` executable slices. / 下载包中同时包含苹果芯片和 Intel 的可执行版本。 |
| Both sounds / 两种铃声 | Both WAV files from the downloaded app loaded, started, and completed playback successfully through macOS audio. / 下载包内的两种 WAV 铃声均可加载、开始播放，并由 macOS 报告成功播放结束。 |
| ChatGPT/Codex detection / 事件检测 | Completion, permission, and structured-question cases passed. / 回复完成、权限请求和结构化问题的检测用例均通过。 |
| Claude detection / Claude 事件检测 | Native notification metadata, process/user filtering, reused tags, duplicate rejection, and stale-event rejection passed. / 原生通知元数据、进程及用户过滤、重复使用的标识、重复事件和过期事件处理均通过。 |
| Log following / 日志跟踪 | Startup history ignored; partial lines, truncation, new files, and file replacement passed. / 启动时忽略历史事件；分段写入、文件截断、新文件和文件替换处理均通过。 |
| Claude monitor / Claude 监听进程 | Live native log stream started, stayed running, and stopped successfully on the development Mac. / 在开发用 Mac 上，实际系统日志监听进程可以启动、持续运行并正常停止。 |
| Instructions / 安装说明 | README and release description include matching English and Simplified Chinese steps, direct download, first-launch help, notification setup, and account/device scope. / README 和版本描述均提供一致的英文和简体中文步骤，包括下载、首次打开、通知设置及账号/设备范围。 |

## Limits that remain / 仍存在的限制

- **Claude must submit a native desktop notification.** The helper cannot detect a completion if Claude emits no notification. Other Claude notices can also chime. It cannot tell Claude completion apart from an input request. / **Claude 必须发送原生桌面通知。** 如果 Claude 未发送通知，小助手无法检测到回复完成；其他 Claude 通知也可能触发铃声，且无法区分完成通知和输入请求。
- Live end-to-end completion/input tests have **not** been performed across every Claude Chat/Code/Cowork surface. The live monitor check confirms availability, not every surface's behavior. / 尚未逐一实测 Claude Chat、Code、Cowork 的全部完成及输入请求场景。监听进程检查通过不代表所有场景都发送通知。
- Intel and older supported macOS versions are compiled for, but have not been tested on physical machines in this session. / 已编译 Intel 及较旧 macOS 的支持版本，但本次未在相应实体设备上实测。
- The downloaded app has not been tested through every first-launch/Gatekeeper flow on a clean or company-managed Mac. Follow the documented per-app approval steps; ask IT if restricted. / 未覆盖全新或公司管理的 Mac 上的所有首次启动及安全审批流程；请按说明批准此 App，受限时联系 IT。
- Playback success does not override your Mac's mute, output routing, headphones, or physical speaker volume. / 播放成功不代表可以绕过 Mac 静音、输出设备选择、耳机或扬声器音量设置。
- App or macOS updates may change the diagnostic event formats. / App 或 macOS 更新后，诊断事件格式可能变化。

## Reproduce developer checks / 开发者复现检查

From the repository root / 在仓库根目录运行：

```sh
bash package.sh
```

Optional tests on a logged-in Mac; the audio test **plays both chimes**. These commands do not change your output volume or app settings. / 以下检查可在已登录的 Mac 上运行；音频检查**会播放两种铃声**，不会修改输出音量或 App 设置。

```sh
swiftc -module-cache-path build/module-cache -parse-as-library Tests/AudioSmoke.swift -framework AppKit -o build/audio-smoke
build/audio-smoke "build/ChatGPT Chime.app"

swiftc -module-cache-path build/module-cache Sources/Core.swift Sources/ClaudeMonitor.swift Tests/ClaudeMonitorSmoke.swift -o build/claude-monitor-smoke
build/claude-monitor-smoke
```

[← English + 中文 installation / 中英双语安装说明](../README.md)
