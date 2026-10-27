# ChatGPT Chime 🔔

**A calm sound when ChatGPT finishes a response or needs your input—in the Mac desktop app.**

[**Download the Mac app →**](https://github.com/emilyshen23/chatgpt-chime/releases/latest)

A small bell lives in your Mac menu bar. Two gentle notes mean **your response is ready**; three mean **ChatGPT needs an answer or permission**. You can keep working in another app and hear when it's time to come back.

No coding, terminal commands, API key, browser extension, or ChatGPT plugin installation needed. This is an independent companion app, not an OpenAI product.

## Before you install

- **Mac only: macOS 13 Ventura or newer.** The same download contains Apple Silicon and Intel builds. The build and tests have been run on Apple Silicon; Intel is cross-compiled, with runtime testing still needed.
- **For the ChatGPT/Codex desktop app that writes local desktop notification logs.** The app may appear as ChatGPT or Codex on your Mac. It must write logs under `~/Library/Logs/com.openai.codex`. Browser tabs, mobile, Windows, and desktop editions without these logs aren't supported.
- ChatGPT Chime must stay running. Closing a menu does not quit it; **Quit ChatGPT Chime** does.

## Install in about two minutes

1. **[Open the latest release](https://github.com/emilyshen23/chatgpt-chime/releases/latest).** Under **Assets**, click `ChatGPT-Chime-1.0.0-macOS-universal.zip`. Do **not** download “Source code”—that's for developers.
2. **Unzip the download.** In Finder → Downloads, double-click the ZIP if your browser hasn't already expanded it. You'll get **ChatGPT Chime.app**.
3. **Move the app to Applications.** Drag **ChatGPT Chime.app** into your Mac's **Applications** folder.
4. **Open it.** Double-click **ChatGPT Chime** in Applications. If macOS blocks it because the developer can't be verified, use the first-launch steps below.
5. **Click “Test chime & start.”** You should hear a soft chime. A **bell icon** appears in your Mac menu bar near the clock. There is no Dock window to keep open.
6. **Enable the events in ChatGPT.** In the ChatGPT/Codex desktop app, press **⌘,** → **Notifications**. Set **turn-completion notifications to Always**, and enable **permission and question notifications** where those controls are available. Leave these enabled: the helper uses those events to know when to chime.
7. **Test a real response.** Send ChatGPT a message, switch to another app, and wait for it to finish. You should hear the two-note chime. A tool permission request or structured question should produce the three-note chime.
8. **Optional: start automatically after login.** Open **Mac System Settings → General → Login Items** (or **Login Items & Extensions**, depending on macOS). Under **Open at Login**, click **+** and choose **Applications → ChatGPT Chime**. You only need to do this once.

### If macOS blocks the first launch

This release is locally signed, **not signed with an Apple Developer ID or notarized by Apple**. A downloaded copy may be blocked on first launch.

1. First try opening **ChatGPT Chime.app** from Applications, then dismiss the warning.
2. Open **System Settings → Privacy & Security**.
3. Scroll down to the **Security** section. Look for the message about **ChatGPT Chime** being blocked.
4. If you trust this repository and the download, click **Open Anyway**, authenticate if asked, then confirm **Open**.
5. Return to the app and select **Test chime & start**.

This is a per-app exception; you don't need to disable Gatekeeper or change system-wide security. If a company-managed Mac doesn't offer **Open Anyway**, ask your IT team to approve the app. If macOS reports malware or a damaged app rather than an unidentified developer, stop and report it rather than overriding the warning. [Apple's first-launch guidance](https://support.apple.com/en-gb/102445).

## Everyday controls

Click the **bell in your Mac menu bar**:

| Control | What it does |
| --- | --- |
| Test calm chime | Plays the completion sound immediately. |
| Pause sounds / Resume sounds | Mutes or resumes alerts. Events during a pause aren't replayed. |
| Volume → Soft / Medium / Full | Sets the chime volume and previews it. |
| Status line | Shows the last detected event or a sound failure. |
| Open helper folder | Locates the installed app in Finder. |
| Quit ChatGPT Chime | Stops the helper and all its sounds. |

Volume and pause settings survive restarts. Sound uses your Mac's normal audio output, including connected headphones, and respects system output mute/volume. It plays directly rather than using the native notification sound, so turning off native banner sounds won't mute this helper. Use its own Pause or Quit controls when you need silence.

## Troubleshooting

**The test chime is silent**

- Check your Mac's output device and output volume in **System Settings → Sound**. Your audio may be going to headphones or a display.
- Choose **bell → Volume → Full**, then **Test calm chime**.
- If the menu says **Sound failed**, quit the helper, check audio output, then reopen it.

**The test works, but actual responses don't chime**

- Make sure the helper is **not paused**.
- Confirm ChatGPT's **turn-completion notifications = Always** and permission/question notifications are enabled. Native notification sound alone isn't enough.
- Test a **new** response after starting the helper. It intentionally ignores responses completed before it started.
- If the menu says **Waiting for app logs**, open ChatGPT and send a message. If logs never appear, your desktop edition may not be compatible. In Finder, press **⇧⌘G** and paste `~/Library/Logs/com.openai.codex` to check whether that folder exists.
- If the menu says **Cannot read app logs**, check that you're running both apps as the same Mac user. On a managed device, ask IT about file-access restrictions.
- App updates can change the log format. [Open an issue](https://github.com/emilyshen23/chatgpt-chime/issues) with your macOS version, ChatGPT app version, and whether the test sound works. Please don't paste private logs or conversation content.

**I hear two sounds**

ChatGPT's own chime may also be working. You can turn off **Play sound for notification** for ChatGPT/Codex in **Mac System Settings → Notifications**, while leaving the app's notification events enabled. Don't turn off the in-app notification categories that the helper depends on. Also quit any older **Desktop Chime** helper you used before this release.

**A normal written question doesn't get the three-note sound**

The helper detects permission and structured-question notifications. It doesn't analyze response text. A completed answer ending in “What do you think?” gets the normal completion chime.

**Several chats finish at once**

Events arriving in a short burst are grouped into one chime. Input requests take priority. Old events are never replayed on startup.

## Privacy and how it works

ChatGPT Chime reads the desktop app's local `.log` files in memory, looking for three notification kinds: `turn-complete`, `permission`, and `question`. It follows new lines, handles new/truncated/rotated files, suppresses duplicate notification IDs, and rejects stale events. Polling occurs about once per second.

It doesn't send any data over the network, save log contents, analyze prompt/response text, take screenshots, modify ChatGPT, change its configuration, or require Accessibility/Screen Recording permissions. Its only saved preferences are volume, pause, and whether the welcome screen has been shown. Chime audio is synthesized locally from sine waves; no third-party sound assets are used.

This is an unofficial workaround using the current app's local log format, not a supported notification API. A future ChatGPT update may require a helper update. The setting names may also vary by desktop release. [Official notification documentation](https://learn.chatgpt.com/docs/notifications).

## Update or uninstall

**Update:** Quit ChatGPT Chime from the bell menu, download and unzip the new release, replace the app in Applications, then reopen it. You may need to approve the new downloaded build again in Privacy & Security. There are no automatic updates.

**Uninstall:** Quit ChatGPT Chime, remove it from **Open at Login** if you added it, then move **ChatGPT Chime.app** from Applications to Trash. ChatGPT and its configuration stay untouched.

## For developers

Requires Apple command line developer tools (`xcode-select --install`) and the included macOS Python 3. There are no third-party runtime dependencies.

```sh
git clone https://github.com/emilyshen23/chatgpt-chime.git
cd chatgpt-chime
bash build.sh
open "build/ChatGPT Chime.app"
```

`build.sh` runs detection/file-following tests, compiles both `arm64` and `x86_64` slices for macOS 13+, combines them into a universal binary, generates the original WAVs, and applies/verifies an ad hoc signature. Tests cover event types, duplicates, stale events, partial writes, truncation, new files, and inode replacement.

To create the distributable ZIP and SHA-256 checksum file:

```sh
bash package.sh
```

Release assets appear under `dist/`. Build outputs and local caches aren't committed. GitHub Actions runs the same build and tests on pushes and pull requests. For the published ZIP, download `SHA256SUMS.txt` alongside it and optionally run `shasum -a 256 -c SHA256SUMS.txt` in that download folder.

[MIT License](LICENSE).
