import Foundation

/// A child process, not a privileged service. Predicate limits the stream to
/// this macOS user's Claude notification submissions; no historical replay.
final class ClaudeMonitor {
    private var process: Process?
    private var output: Pipe?
    private var pending = Data()
    private let detector = ClaudeEventDetector()
    var onEvent: ((ChimeEvent) -> Void)?
    var onStatus: ((String) -> Void)?
    private(set) var running = false

    func start() {
        guard process == nil else { return }
        let child = Process()
        let pipe = Pipe()
        child.executableURL = URL(fileURLWithPath: "/usr/bin/log")
        child.arguments = ["stream", "--style", "ndjson", "--info", "--predicate",
            "process == \"Claude\" AND subsystem == \"com.apple.UserNotifications\" AND userID == \(getuid()) AND eventMessage CONTAINS \"[com.anthropic.claudefordesktop] Adding notification request\""]
        child.standardOutput = pipe
        child.standardError = FileHandle.nullDevice
        pipe.fileHandleForReading.readabilityHandler = { [weak self] handle in
            let data = handle.availableData
            guard !data.isEmpty else { return }
            DispatchQueue.main.async { self?.receive(data) }
        }
        child.terminationHandler = { [weak self] child in
            DispatchQueue.main.async {
                guard let self = self, self.process === child else { return }
                self.stop()
                self.onStatus?("Claude: monitor unavailable (quit and reopen to retry)")
            }
        }
        process = child; output = pipe
        do {
            try child.run()
            running = true
            onStatus?("Claude: listening for desktop notifications")
        } catch {
            stop()
            onStatus?("Claude: monitor unavailable")
        }
    }
    private func receive(_ data: Data) {
        guard running else { return }
        pending.append(data)
        guard let lastNewline = pending.lastIndex(of: 10) else {
            if pending.count > 262_144 { pending.removeAll() }
            return
        }
        let complete = pending.prefix(through: lastNewline)
        let lines = String(decoding: complete, as: UTF8.self).split(separator: "\n")
        pending = Data(pending.suffix(from: lastNewline + 1))
        for line in lines {
            if let event = detector.consume(String(line)) { onEvent?(event) }
        }
    }
    func stop() {
        let child = process
        process = nil; running = false
        output?.fileHandleForReading.readabilityHandler = nil
        try? output?.fileHandleForReading.close()
        output = nil; pending.removeAll()
        child?.terminationHandler = nil
        if child?.isRunning == true { child?.terminate() }
    }
    deinit { stop() }
}
