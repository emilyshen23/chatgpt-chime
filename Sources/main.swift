import AppKit

final class ChimeApp: NSObject, NSApplicationDelegate {
    private var item: NSStatusItem!
    private var timer: Timer?
    private var follower: LogFollower!
    private let detector = EventDetector()
    private var sound: NSSound?
    private var pendingKind: String?
    private var playTimer: Timer?
    private var lastStatus = "Listening for ChatGPT"
    private let defaults = UserDefaults.standard
    private var enabled: Bool { !defaults.bool(forKey: "paused") }
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
        refresh()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in self?.poll() }
        if !defaults.bool(forKey: "hasOpened") {
            defaults.set(true, forKey: "hasOpened")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                let welcome = NSAlert()
                welcome.messageText = "ChatGPT Chime is listening"
                welcome.informativeText = "A calm chime plays when a response is ready or ChatGPT needs input.\n\nFind the bell in your Mac menu bar to test, pause, or adjust volume. Keep ChatGPT’s completion notifications set to Always and permission/question notifications enabled.\n\nThe helper stays open until you quit it or log out."
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
        if let error = follower.error {
            menu.addItem(withTitle: error, action: nil, keyEquivalent: "").isEnabled = false
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
        guard enabled else { return }
        for event in events {
            // Several chats finishing together produce one sound. Input requests
            // take precedence over completion during this short debounce window.
            if pendingKind == nil || event.kind != "turn-complete" { pendingKind = event.kind }
            if playTimer == nil {
                playTimer = Timer.scheduledTimer(withTimeInterval: 0.35, repeats: false) { [weak self] _ in
                    guard let self = self else { return }
                    if self.enabled, let kind = self.pendingKind { self.play(kind) }
                    self.pendingKind = nil; self.playTimer = nil
                }
            }
        }
        if !events.isEmpty { refresh() }
    }
    private func play(_ kind: String) {
        let name = kind == "turn-complete" ? "calm-ready" : "calm-input"
        guard let path = Bundle.main.path(forResource: name, ofType: "wav"),
              let next = NSSound(contentsOfFile: path, byReference: false) else {
            lastStatus = "Chime file missing"; refresh(); return
        }
        sound?.stop(); sound = next; next.volume = volume
        if next.play() {
            lastStatus = kind == "turn-complete" ? "Last event: response ready" : "Last event: input needed"
        } else { lastStatus = "Sound failed — check audio output" }
        refresh()
    }
    @objc private func test() { play("turn-complete") }
    @objc private func toggle() {
        defaults.set(enabled, forKey: "paused")
        pendingKind = nil; sound?.stop(); refresh()
    }
    @objc private func changeVolume(_ sender: NSMenuItem) {
        defaults.set(Float(sender.tag) / 100, forKey: "volume")
        play("turn-complete")
    }
    @objc private func reveal() { NSWorkspace.shared.selectFile(Bundle.main.bundlePath, inFileViewerRootedAtPath: "") }
    @objc private func quit() { NSApp.terminate(nil) }
}

let app = NSApplication.shared
let delegate = ChimeApp()
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
