## ChatGPT Chime for Mac

A calm sound when the ChatGPT/Codex desktop app finishes a response or needs input. A small bell in the menu bar gives you test, volume, pause, and quit controls.

### Install — no coding needed

1. Under **Assets** below, download **ChatGPT-Chime-1.0.0-macOS-universal.zip**. Don't choose “Source code.”
2. Unzip it and drag **ChatGPT Chime.app** into **Applications**.
3. Open the app. If macOS blocks the unidentified developer, go to **System Settings → Privacy & Security → Security → Open Anyway**, authenticate, and confirm **Open**. This release is locally signed but not Apple-notarized. On a managed company Mac, IT may need to approve it.
4. Click **Test chime & start**. Find the **bell icon near the clock** for volume, pause, test, or quit.
5. In the **ChatGPT/Codex desktop app → Settings → Notifications**, set **turn completion = Always**, and enable **permission/question notifications** where available. Keep these event categories enabled.
6. Send a new message and switch apps: **two notes = response ready; three notes = input/approval needed**.
7. Optional: add **ChatGPT Chime** to **System Settings → General → Login Items → Open at Login** so it starts each time you sign in.

**Requirements:** macOS 13+ and the ChatGPT/Codex desktop edition that writes `~/Library/Logs/com.openai.codex`. This helper doesn't cover browser, mobile, Windows, or desktop editions without those logs. One download includes Apple Silicon and Intel; tests ran on Apple Silicon, with Intel runtime testing still needed.

**Privacy:** local log-event matching only. No network requests, API key, screen access, or ChatGPT changes. The helper depends on the current app log format and may need updating after app changes.

**[Full instructions, first-launch help, and troubleshooting](https://github.com/emilyshen23/chatgpt-chime#readme)**

To update an older helper, quit it before replacing the app. If you used the original **Desktop Chime**, quit that too so you don't get duplicate sounds. Download `SHA256SUMS.txt` alongside the ZIP if you want to verify its checksum.
