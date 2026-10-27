import AppKit

final class ChimeApp: NSObject, NSApplicationDelegate {
    private var item: NSStatusItem!
    private var timer: Timer?
    private var follower: LogFollower!
    private let detector = EventDetector()
    private var sound: NSSound?
    private var pendingEvent: ChimeEvent?
    private let claude = ClaudeMonitor()
    private var claudeStatus = "Claude: starting"
    private var playTimer: Timer?
    private var lastStatus = "Listening for desktop activity"
    private let defaults = UserDefaults.standard
    private var enabled: Bool { !defaults.bool(forKey: "paused") }
    private func watches(_ source: String) -> Bool { !defaults.bool(forKey: "muted.\(source)") }
    private var volume: Float { defaults.object(forKey: "volume") == nil ? 0.65 : defaults.float(forKey: "volume") }

    func applicationDidFinishLaunching(_ notification: Notification) {
        // One menu bar helper per user, even if opened repeatedly.
        if NSRunningApplication.runningApplications(withBundleIdentifier: "io.github.emilyshen23.chatgpt-chime")
            .contains(where: { $0.processIdentifier != ProcessInfo.processInfo.processIdentifier }) {
            NSApp.terminate(nil); return
        }
        let root = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Library/Logs/com.openai.codex")
        follower = LogFollower(root: root)
        item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        claude.onEvent = { [weak self] event in self?.enqueue(event) }
        claude.onStatus = { [weak self] status in self?.claudeStatus = status; self?.refresh() }
        refresh()
        if watches("claude") { claude.start() }
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in self?.poll() }
        if !defaults.bool(forKey: "hasOpened") {
            defaults.set(true, forKey: "hasOpened")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                let welcome = NSAlert()
                welcome.messageText = "ChatGPT Chime is listening"
                welcome.informativeText = "One helper for ChatGPT/Codex and Claude.\n\nChatGPT/Codex: chimes for response completion or input requests. Keep its notification categories enabled.\n\nClaude: chimes when Claude submits a native desktop notification, including other notices. Enable Claude’s notification settings.\n\nUse the bell menu to toggle either app, test, pause, or adjust volume. This runs on this Mac user account; it does not sync to other devices."
                welcome.addButton(withTitle: "Test chime & start")
                welcome.addButton(withTitle: "Start quietly")
                NSApp.activate(ignoringOtherApps: true)
                if welcome.runModal() == .alertFirstButtonReturn { self.play("turn-complete") }
            }
        } else if CommandLine.arguments.contains("--test-sound") {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { self.play("turn-complete") }
        }
    }
    private func refresh() {
        item.button?.image = NSImage(systemSymbolName: enabled ? "bell.badge" : "bell.slash", accessibilityDescription: "ChatGPT Chime")
        item.button?.toolTip = "ChatGPT Chime — \(enabled ? lastStatus : "Paused")"
        let menu = NSMenu()
        let title = menu.addItem(withTitle: "ChatGPT Chime", action: nil, keyEquivalent: "")
        title.isEnabled = false
        let status = menu.addItem(withTitle: enabled ? lastStatus : "Paused", action: nil, keyEquivalent: "")
        status.isEnabled = false
        if watches("codex"), let error = follower.error {
            menu.addItem(withTitle: error, action: nil, keyEquivalent: "").isEnabled = false
        }
        if watches("claude") {
            menu.addItem(withTitle: claudeStatus, action: nil, keyEquivalent: "").isEnabled = false
        }
        menu.addItem(.separator())
        for (label, source) in [("ChatGPT / Codex", "codex"), ("Claude desktop notifications", "claude")] {
            let toggle = menu.addItem(withTitle: label, action: #selector(toggleSource(_:)), keyEquivalent: "")
            toggle.target = self; toggle.representedObject = source
            toggle.state = watches(source) ? .on : .off
        }
        menu.addItem(.separator())
        add(menu, "Test calm chime", #selector(test))
        add(menu, enabled ? "Pause sounds" : "Resume sounds", #selector(toggle))
        let volumes = NSMenu()
        for (label, level) in [("Soft", 35), ("Medium", 65), ("Full", 100)] {
            let entry = volumes.addItem(withTitle: label, action: #selector(changeVolume(_:)), keyEquivalent: "")
            entry.target = self; entry.tag = level
            entry.state = abs(volume - Float(level) / 100) < 0.01 ? .on : .off
        }
        let entry = menu.addItem(withTitle: "Volume", action: nil, keyEquivalent: "")
        entry.submenu = volumes
        menu.addItem(.separator())
        add(menu, "Open helper folder", #selector(reveal))
        add(menu, "Quit ChatGPT Chime", #selector(quit))
        item.menu = menu
    }
    private func add(_ menu: NSMenu, _ title: String, _ action: Selector) {
        let entry = menu.addItem(withTitle: title, action: action, keyEquivalent: "")
        entry.target = self
    }
    private func poll() {
        let previousError = follower.error
        let events = follower.poll().compactMap { detector.consume($0) }
        if previousError != follower.error { refresh() }
        for event in events { enqueue(event) }
    }
    private func enqueue(_ event: ChimeEvent) {
        guard enabled, watches(event.source) else { return }
        // A known input request takes priority over generic attention/completion.
        if pendingEvent == nil || ["permission", "question"].contains(event.kind) { pendingEvent = event }
        if playTimer == nil {
            playTimer = Timer.scheduledTimer(withTimeInterval: 0.35, repeats: false) { [weak self] _ in
                guard let self = self else { return }
                if self.enabled, let event = self.pendingEvent, self.watches(event.source) {
                    self.play(event.kind, source: event.source)
                }
                self.pendingEvent = nil; self.playTimer = nil
            }
        }
    }
    private func play(_ kind: String, source: String = "codex") {
        let name = ["turn-complete", "attention"].contains(kind) ? "calm-ready" : "calm-input"
        guard let path = Bundle.main.path(forResource: name, ofType: "wav"),
              let next = NSSound(contentsOfFile: path, byReference: false) else {
            lastStatus = "Chime file missing"; refresh(); return
        }
        sound?.stop(); sound = next; next.volume = volume
        if next.play() {
            lastStatus = source == "claude" ? "Last event: Claude desktop notification" :
                (kind == "turn-complete" ? "Last event: ChatGPT/Codex response ready" : "Last event: ChatGPT/Codex input needed")
        } else { lastStatus = "Sound failed — check audio output" }
        refresh()
    }
    @objc private func test() { play("turn-complete") }
    @objc private func toggle() {
        defaults.set(enabled, forKey: "paused")
        pendingEvent = nil; sound?.stop(); refresh()
    }
    @objc private func toggleSource(_ sender: NSMenuItem) {
        guard let source = sender.representedObject as? String else { return }
        defaults.set(watches(source), forKey: "muted.\(source)")
        if pendingEvent?.source == source { pendingEvent = nil }
        if source == "claude" {
            if watches(source) { claude.start() } else { claude.stop() }
        }
        refresh()
    }
    @objc private func changeVolume(_ sender: NSMenuItem) {
        defaults.set(Float(sender.tag) / 100, forKey: "volume")
        play("turn-complete")
    }
    @objc private func reveal() { NSWorkspace.shared.selectFile(Bundle.main.bundlePath, inFileViewerRootedAtPath: "") }
    func applicationWillTerminate(_ notification: Notification) { claude.stop() }
    @objc private func quit() { NSApp.terminate(nil) }
}

let app = NSApplication.shared
let delegate = ChimeApp()
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
