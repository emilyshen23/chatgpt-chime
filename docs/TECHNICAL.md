# ChatGPT Chime — technical reference

[← Easy English + 中文 installation guide](../README.md)

Technical details, extended troubleshooting, and build instructions. For normal installation, use the guide above.

[**Download the Mac app →**](https://github.com/emilyshen23/chatgpt-chime/releases/latest)

A small bell lives in your Mac menu bar. For ChatGPT/Codex, two gentle notes mean **response ready** and three mean **input or permission needed**. For Claude, two notes mean **Claude submitted a desktop notification**. Each app has its own on/off switch. You can keep working in another app and hear when it's time to come back.

No coding, terminal commands, API key, browser extension, or ChatGPT plugin installation needed. This is an independent companion app, not an OpenAI product.

## Before you install

- **Mac only: macOS 13 Ventura or newer.** The same download contains Apple Silicon and Intel builds. The build and tests have been run on Apple Silicon; Intel is cross-compiled, with runtime testing still needed.
- **ChatGPT/Codex:** supports the desktop app that writes local logs under `~/Library/Logs/com.openai.codex`. Desktop editions without those logs are not supported.
- **Claude:** observes native macOS notification submissions from Claude Desktop. Claude must actually submit a notification; a silent/no-notification completion cannot be detected by this adapter. It may also chime for unrelated Claude notifications.
- Browser-only use, mobile, and Windows are not supported. The two adapters are independent: you can use Claude even if ChatGPT/Codex is not installed, or vice versa.
- ChatGPT Chime must stay running. Closing a menu does not quit it; **Quit ChatGPT Chime** does.

## Install in about two minutes

1. **[Open the latest release](https://github.com/emilyshen23/chatgpt-chime/releases/latest).** Under **Assets**, click `ChatGPT-Chime-1.1.0-macOS-universal.zip`. Do **not** download “Source code”—that's for developers.
2. **Unzip the download.** In Finder → Downloads, double-click the ZIP if your browser hasn't already expanded it. You'll get **ChatGPT Chime.app**.
3. **Move the app to Applications.** Drag **ChatGPT Chime.app** into your Mac's **Applications** folder.
4. **Open it.** Double-click **ChatGPT Chime** in Applications. If macOS blocks it because the developer can't be verified, use the first-launch steps below.
5. **Click “Test chime & start.”** You should hear a soft chime. A **bell icon** appears in your Mac menu bar near the clock. There is no Dock window to keep open.
6. **Enable the events in ChatGPT.** In the ChatGPT/Codex desktop app, press **⌘,** → **Notifications**. Set **turn-completion notifications to Always**, and enable **permission and question notifications** where those controls are available. Leave these enabled: the helper uses those events to know when to chime.
7. **If you use Claude, enable its notifications too.** In Claude → Settings, enable response-completion/task/permission notifications where available. In **Mac System Settings → Notifications → Claude**, allow notifications. Switch to another app while a Claude task runs. The helper chimes when Claude submits a native notification; some Claude editions/surfaces suppress notifications while focused or do not emit them for ordinary chat.
8. **Test each app you use.** Send a new message, switch apps, and wait. ChatGPT/Codex completion should produce two notes; its structured question or permission request should produce three. Claude desktop notifications produce two notes, without a completion/input distinction. In the bell menu, uncheck any app you do not want to hear.
9. **Optional: start automatically after login.** Open **Mac System Settings → General → Login Items** (or **Login Items & Extensions**, depending on macOS). Under **Open at Login**, click **+** and choose **Applications → ChatGPT Chime**. You only need to do this once.

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
| ChatGPT / Codex | Turns the ChatGPT/Codex adapter on or off. |
| Claude desktop notifications | Turns the Claude adapter on or off. |
| Test calm chime | Plays the completion sound immediately. |
| Pause sounds / Resume sounds | Mutes or resumes alerts. Events during a pause aren't replayed. |
| Volume → Soft / Medium / Full | Sets the chime volume and previews it. |
| Status line | Shows the last detected event or a sound failure. |
| Open helper folder | Locates the installed app in Finder. |
| Quit ChatGPT Chime | Stops the helper and all its sounds. |

Volume, pause, and per-app switches survive restarts. Sound uses your Mac's normal audio output, including connected headphones, and respects system output mute/volume. It plays directly rather than using the native notification sound, so turning off native banner sounds won't mute this helper. Use its own Pause or Quit controls when you need silence.

## Is this per device or per account?

**Per macOS user on each Mac—not per ChatGPT or Claude account.** It runs locally for the person logged into the Mac. It follows events from the local apps even if you switch AI accounts. There is no login to this helper, account connection, cloud sync, or team-wide installation from one person's computer.

Each teammate installs and starts their own copy. A second Mac needs its own installation. Separate macOS user accounts on a shared Mac each need their own setup. It cannot alert you on this Mac about a chat running only on someone else's computer or your phone. If a cloud/remote chat emits a notification in your local app, that local notification may trigger a chime.

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

**Claude is enabled but never chimes**

- Verify **bell → Claude desktop notifications** is checked, and look at the Claude status line.
- Check Claude's own notification preferences and macOS notification permission. Switch to another app for the test; Claude can suppress notifications while it is focused.
- This adapter observes submissions to macOS, not chat content. If Claude does not submit a native notification for a particular Chat/Code/Cowork action, there is no event to chime for. A working test sound does not establish support for every Claude surface.
- If the menu says **Claude: monitor unavailable**, quit and reopen the helper. The adapter uses macOS's built-in `log stream` as your normal user, without administrator access. Managed Macs may restrict access; ask IT rather than granting broad permissions.
- Uncheck and recheck **Claude desktop notifications** to restart its monitor. The ChatGPT/Codex adapter continues independently if Claude monitoring is unavailable.

**I hear two sounds**

The AI app's own chime may also be working. You can turn off **Play sound for notification** for ChatGPT/Codex in **Mac System Settings → Notifications**, while leaving the app's notification events enabled. Don't turn off the in-app notification categories that the helper depends on. Also quit any older **Desktop Chime** helper you used before this release.

**A normal written question doesn't get the three-note sound**

The helper detects permission and structured-question notifications. It doesn't analyze response text. A completed answer ending in “What do you think?” gets the normal completion chime.

**Several chats finish at once**

Events arriving in a short burst are grouped into one chime. Input requests take priority. Old events are never replayed on startup.

## Privacy and how it works

**ChatGPT/Codex adapter:** ChatGPT Chime reads the desktop app's local `.log` files in memory, looking for three notification kinds: `turn-complete`, `permission`, and `question`. It follows new lines, handles new/truncated/rotated files, suppresses duplicate notification IDs, and rejects stale events. Polling occurs about once per second.

**Claude adapter:** runs the built-in macOS `log stream` command with a predicate restricted to Claude's native notification submissions and your macOS user ID. It validates the process, bundle identifier, user ID, timestamp, and request metadata in memory. It does not examine notification body text, infer completion from generic idle messages, or retain system log output. Claude's reused notification tags can still chime on subsequent submissions. Claude notifications are generic attention events, so other notices may also produce a sound. The subprocess stops when Claude is unchecked or the helper quits.

It doesn't send any data over the network, save log contents, analyze prompt/response text, take screenshots, modify ChatGPT, change its configuration, or require Accessibility/Screen Recording permissions. Its only saved preferences are volume, pause, app switches, and whether the welcome screen has been shown. Chime audio is synthesized locally from sine waves; no third-party sound assets are used.

This is an unofficial workaround using local desktop logs and macOS diagnostic event formats, not an integration supported by OpenAI or Anthropic. A future app or macOS update may require a helper update. Claude support was checked against real notification metadata on one Mac and automated fixtures; a full live completion/input test across every Claude surface has not been performed. The setting names may also vary by desktop release. [Official notification documentation](https://learn.chatgpt.com/docs/notifications).

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

`build.sh` runs detection/file-following tests, compiles both `arm64` and `x86_64` slices for macOS 13+, combines them into a universal binary, generates the original WAVs, and applies/verifies an ad hoc signature. Tests cover Codex event types, Claude metadata/process/user filtering and reused tags, duplicates, stale events, partial writes, truncation, new files, and inode replacement.

To create the distributable ZIP and SHA-256 checksum file:

```sh
bash package.sh
```

Release assets appear under `dist/`. Build outputs and local caches aren't committed. GitHub Actions runs the same build and tests on pushes and pull requests. For the published ZIP, download `SHA256SUMS.txt` alongside it and optionally run `shasum -a 256 -c SHA256SUMS.txt` in that download folder.

[MIT License](../LICENSE).
