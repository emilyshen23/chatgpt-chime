## v1.1.0 — One helper for ChatGPT/Codex and Claude

Adds a **Claude desktop notifications** switch next to **ChatGPT / Codex** in the existing menu bar app. Install one helper and enable either or both.

| App | What triggers a calm chime |
| --- | --- |
| ChatGPT / Codex | Response completion (two notes), permission or structured question (three notes), using local app notification logs. |
| Claude Desktop | A native macOS notification submission (two notes). This can include completion/input notifications and other Claude notices. Claude must actually emit a notification. |

### Install or update

1. Download **ChatGPT-Chime-1.1.0-macOS-universal.zip** from **Assets** below. Do not choose “Source code.”
2. **Quit the old helper** from its bell menu, including the original **Desktop Chime** if present.
3. Unzip and move **ChatGPT Chime.app** to **Applications**, replacing the old copy. Open it.
4. If macOS blocks the unidentified developer, use **System Settings → Privacy & Security → Security → Open Anyway** for this app. The build is locally signed, not Apple-notarized; managed Macs may need IT approval.
5. Find the **bell near the clock**. Check **ChatGPT / Codex**, **Claude desktop notifications**, or both. Use **Test calm chime** and the volume menu to verify sound.
6. **ChatGPT/Codex:** Settings → Notifications → turn completion **Always**; enable permission/question notifications where offered.
7. **Claude:** enable its own response/task/permission notifications where offered, and allow Claude in Mac System Settings → Notifications. Switch apps during the test: Claude can suppress notifications while focused. If Claude never submits a notification for a chat surface, the helper cannot detect that completion.
8. Optional: **System Settings → General → Login Items → Open at Login → + → ChatGPT Chime**.

### Per device, not AI account

Runs **locally for your macOS user on each Mac**. No ChatGPT/Claude account login to the helper, no cloud sync. Each teammate and each Mac needs its own installation. Switching AI accounts does not require reinstalling it.

### Compatibility and verification

macOS 13+, Apple Silicon or Intel. Intel is cross-compiled; live testing is still needed. Claude uses a narrowly filtered macOS `log stream` child process and does not need administrator, Accessibility, or screen recording permissions. Managed Mac restrictions or app/macOS changes may prevent this signal from being available. It does not read notification bodies or infer completion from generic idle messages.

Automated tests cover Claude event metadata, user/process filtering, duplicate/stale rejection, reused notification tags, and the existing Codex/log-following behavior. Real Claude notification metadata was inspected on one Mac; live end-to-end completion/input behavior on every Claude surface is not yet verified.

**[Full setup guide, account/device explanation, and troubleshooting](https://github.com/emilyshen23/chatgpt-chime#readme)**

Download `SHA256SUMS.txt` alongside the ZIP if you want to verify its checksum. Source and audio generation are included; no API key, external service, or changes to the AI apps.
