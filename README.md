# ChatGPT Chime 🔔

**Calm sounds for ChatGPT/Codex and Claude on your Mac.**

**让 Mac 上的 ChatGPT/Codex 和 Claude 用轻柔的铃声提醒你。**

## [⬇ Download for Mac / 下载 Mac 版](https://github.com/emilyshen23/chatgpt-chime/releases/download/v1.1.0/ChatGPT-Chime-1.1.0-macOS-universal.zip)

[English instructions](#english) · [中文安装说明](#中文) · [Latest release / 最新版本](https://github.com/emilyshen23/chatgpt-chime/releases/latest)

Mac only · macOS 13+ · One download for Apple Silicon and Intel · No coding or API key

仅支持 Mac · macOS 13 及以上 · 同一安装包支持苹果芯片和 Intel · 无需编程或 API 密钥

## English

### Install in 5 steps

1. **[Download the ZIP](https://github.com/emilyshen23/chatgpt-chime/releases/download/v1.1.0/ChatGPT-Chime-1.1.0-macOS-universal.zip).** If you're on the release page, choose `ChatGPT-Chime-1.1.0-macOS-universal.zip` under **Assets**, not “Source code.”
2. **Unzip it.** Double-click the ZIP in Downloads. You'll see **ChatGPT Chime.app**.
3. **Drag the app into Applications**, then double-click it there. If blocked, follow **“Mac won't open it”** below. Updating? Quit the old helper from its bell menu before replacing it.
4. **Click “Test chime & start.”** You should hear a gentle sound. Find the **bell icon near the clock** in your Mac menu bar. If you're updating and no welcome window appears, use **bell → Test calm chime**.
5. **Choose your apps.** In the bell menu, check **ChatGPT / Codex**, **Claude desktop notifications**, or both. Enable their notification settings below, then send a new message and switch to another app to test.

**Keep the helper running.** It has a menu-bar bell, not a normal Dock window. Use the bell to pause, adjust volume, or quit.

### Enable notifications in the app you use

| App | What to turn on | What you hear |
| --- | --- | --- |
| ChatGPT / Codex | Open its **Settings → Notifications**. Set **turn completion = Always**; enable permission/question notifications where offered. | Two notes when ready; three for permission or a structured question. |
| Claude | In **Claude → Settings**, enable response/task/permission notifications where offered. Also allow **Mac System Settings → Notifications → Claude**. Test while using another app. | Two notes when Claude submits a native desktop notification. Other Claude notices may also chime. |

**Claude limit:** if Claude doesn't send a desktop notification for a particular chat or task, this helper cannot detect its completion. It does not distinguish Claude completion from input requests. A test chime checks audio only; test a real task too.

**ChatGPT/Codex compatibility:** requires the desktop edition that writes logs to `~/Library/Logs/com.openai.codex`. Not every ChatGPT desktop edition does. Browser-only use, mobile, and Windows are not supported.

### Mac won't open it

This app is **not Apple-notarized**, so macOS may block the first launch.

After trying to open it, go to **System Settings → Privacy & Security**, scroll to **Security**, and click **Open Anyway** for **ChatGPT Chime**. Authenticate and confirm **Open**, if you trust this download. On a company-managed Mac, ask IT if this option is unavailable. Don't disable your Mac's security settings. If macOS reports malware or a damaged app, stop and report it. [Apple's instructions](https://support.apple.com/en-gb/102445).

### Start automatically after login — optional

**System Settings → General → Login Items** (or **Login Items & Extensions**) → **Open at Login → +** → select **Applications → ChatGPT Chime**.

### No sound?

1. Click **bell → Test calm chime**. Check **Volume → Full**, your Mac's output volume, and connected headphones.
2. Make sure sounds aren't paused and your app is checked in the bell menu.
3. Recheck the notification settings above. Send a **new** message after starting the helper, then switch apps.
4. Claude still silent? It may not be sending a native notification. **Claude: monitor unavailable**? Uncheck and recheck the Claude switch; managed Macs may restrict system-log access.
5. **Waiting for app logs**? Open ChatGPT/Codex and send a message. If it stays that way, that desktop edition may not be compatible.

[More troubleshooting](docs/TECHNICAL.md#troubleshooting) · [Report a problem](https://github.com/emilyshen23/chatgpt-chime/issues)

### Per device or account?

**Per macOS user on each Mac, not your ChatGPT or Claude account.** Each teammate installs their own copy. A second Mac needs its own installation. Switching AI accounts does not require reinstalling. There is no account login to this helper or cross-device sync.

## 中文

### 5 步完成安装

1. **[下载 ZIP 安装包](https://github.com/emilyshen23/chatgpt-chime/releases/download/v1.1.0/ChatGPT-Chime-1.1.0-macOS-universal.zip)。** 如果你在版本发布页面，请在 **Assets（资源）** 下选择 `ChatGPT-Chime-1.1.0-macOS-universal.zip`，不要下载 “Source code（源代码）”。
2. **解压。** 在“下载”文件夹中双击 ZIP，找到 **ChatGPT Chime.app**。
3. **把 App 拖入“应用程序”文件夹，再双击打开。** 如果 Mac 阻止打开，请看下面的“Mac 不让打开怎么办”。更新旧版时，请先点击旧版的铃铛菜单，选择退出，再替换 App。
4. **点击 “Test chime & start”（测试铃声并启动）。** 你应该能听到轻柔的铃声。屏幕顶部菜单栏、时钟附近会出现一个**铃铛图标**。更新后如果没有欢迎窗口，点击**铃铛 → Test calm chime（测试铃声）** 即可。
5. **选择需要提醒的 App。** 在铃铛菜单中勾选 **ChatGPT / Codex**、**Claude desktop notifications（Claude 桌面通知）**，或者同时勾选。按照下表开启通知，然后发送一条新消息，切换到其他 App，等待提醒。

**使用时请保持小助手运行。** 它显示在顶部菜单栏，不会像普通 App 一样一直出现在 Dock 中。点击铃铛可以暂停、调整音量或退出。

### 开启你所用 App 的通知

| App | 需要开启的设置 | 铃声含义 |
| --- | --- | --- |
| ChatGPT / Codex | 打开该 App 的 **Settings（设置）→ Notifications（通知）**，把回复完成通知设为 **Always（始终）**；如果有权限请求、提问通知选项，也请开启。 | 两个音符：回复已完成；三个音符：需要授权或回答结构化问题。 |
| Claude | 在 **Claude → Settings（设置）** 中开启可用的回复完成、任务和权限通知；同时在 **Mac 系统设置 → 通知 → Claude** 中允许通知。测试时请切换到其他 App。 | Claude 向 macOS 提交桌面通知时播放两个音符；其他 Claude 通知也可能触发铃声。 |

**Claude 的限制：** 如果 Claude 没有为某次聊天或任务发送桌面通知，小助手就无法检测到它已完成。Claude 的完成和输入请求使用同一种铃声。“测试铃声”只验证音频，还需要用真实任务测试一次。

**ChatGPT/Codex 的兼容范围：** 需要使用会在 `~/Library/Logs/com.openai.codex` 中写入日志的桌面版本，并非所有 ChatGPT 桌面版本都支持。不支持仅在浏览器中使用、手机端或 Windows。

### Mac 不让打开怎么办？

本版本**未经 Apple 公证**，首次打开时可能被 macOS 阻止。

先尝试打开 App，再前往 **系统设置 → 隐私与安全性 → 安全性**，找到 **ChatGPT Chime**，点击 **“仍要打开”（Open Anyway）**。如果你信任此下载，请按提示验证身份并确认打开。公司管理的 Mac 如果没有此选项，请联系 IT。无需关闭 Mac 的系统安全保护。如果提示恶意软件或 App 已损坏，请停止操作并反馈。[Apple 操作说明](https://support.apple.com/en-gb/102445)。

### 开机登录后自动启动（可选）

打开 **系统设置 → 通用 → 登录项**（部分版本显示“登录项与扩展”），在 **“登录时打开”** 中点击 **+**，选择 **应用程序 → ChatGPT Chime**。

### 听不到声音？

1. 点击**铃铛 → Test calm chime（测试铃声）**。把 **Volume（音量）→ Full（最大）**，并检查 Mac 音量及连接的耳机。
2. 确认没有暂停提醒，且铃铛菜单中已勾选你使用的 App。
3. 检查上面的通知设置。启动小助手后发送一条**新消息**，然后切换到其他 App。
4. Claude 仍无声？它可能没有发送桌面通知。如果显示 **Claude: monitor unavailable（Claude 监听不可用）**，取消并重新勾选 Claude；公司设备可能限制系统日志访问。
5. 如果显示 **Waiting for app logs（等待 App 日志）**，打开 ChatGPT/Codex 并发送消息。始终没有变化，可能是当前桌面版本不兼容。

[反馈问题](https://github.com/emilyshen23/chatgpt-chime/issues)：请提供 macOS 版本、AI App 版本，以及“测试铃声”是否正常。不要上传私人聊天内容或完整日志。

### 是绑定设备，还是绑定 AI 账号？

**按每台 Mac 的 macOS 用户运行，不绑定 ChatGPT 或 Claude 账号。** 每位同事需要自行安装；另一台 Mac 需要单独安装。切换 AI 账号无需重装。本工具不需要登录账号，也不会跨设备同步设置或提醒。

## Update / 更新 · Remove / 卸载

**Update:** Bell → **Quit ChatGPT Chime**, download the new version, replace the app in Applications, and reopen it. Also quit the older **Desktop Chime** if present to avoid duplicate sounds.

**更新：** 点击铃铛 → **Quit ChatGPT Chime（退出）**，下载新版，替换“应用程序”中的旧版，再打开。如果之前安装过 **Desktop Chime**，也请退出，避免重复提醒。

**Remove:** Quit the helper, remove it from Login Items if added, then move the app to Trash.

**卸载：** 退出小助手；如果设置过登录时启动，请从“登录项”中移除；最后把 App 移到废纸篓。

## Privacy / 隐私

Local event matching only. No network requests, API keys, screenshots, saved chat content, or changes to the AI apps. This is an independent tool, not an OpenAI or Anthropic product. App/macOS updates may change compatibility.

仅在本机匹配事件；不发送网络请求，不需要 API 密钥，不截屏，不保存聊天内容，也不会修改 AI App。本工具不是 OpenAI 或 Anthropic 官方产品。App 或 macOS 更新后，兼容性可能发生变化。

## Verification / 验证情况

[Checks performed and remaining limits / 已完成的检查及限制](docs/VERIFICATION.md) · [Technical details and developer build instructions / 技术详情及开发构建说明（英文）](docs/TECHNICAL.md) · [MIT License](LICENSE)
