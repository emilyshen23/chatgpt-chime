import Foundation

@main struct Tests {
    static func main() throws {
        let start = Date()
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let stamp = formatter.string(from: start.addingTimeInterval(1))
        func line(_ kind: String, _ id: String = "test-1") -> String {
            "\(stamp) info [desktop-notifications] show notification actionCount=0 kind=\(kind) notificationId=\(id)"
        }
        let detector = EventDetector(start: start)
        let now = start.addingTimeInterval(2)
        precondition(detector.consume(line("turn-complete"), now: now)?.kind == "turn-complete")
        precondition(detector.consume(line("turn-complete"), now: now) == nil, "Duplicate must be silent")
        precondition(detector.consume(line("permission"), now: now)?.kind == "permission")
        precondition(detector.consume(line("question"), now: now)?.kind == "question")
        precondition(detector.consume(line("unknown"), now: now) == nil)
        precondition(detector.consume(line("question", "undefined"), now: now) == nil)
        precondition(detector.consume(line("question", "stale"), now: start.addingTimeInterval(60)) == nil)
        precondition(EventDetector(start: now).consume(line("question"), now: now) == nil, "No historical replay")
        precondition(detector.consume("\(stamp) info [notifications-service] [desktop-notifications] forward show kind=question notificationId=test", now: now) == nil)
        precondition(detector.consume("\(stamp) error [desktop-notifications][global-error] question", now: now) == nil)

        let nativeDate = DateFormatter()
        nativeDate.locale = Locale(identifier: "en_US_POSIX")
        nativeDate.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSSZ"
        let claude = ClaudeEventDetector(start: start)
        func native(_ changes: [String: Any] = [:]) -> String {
            var record: [String: Any] = [
                "timestamp": nativeDate.string(from: start.addingTimeInterval(1)),
                "userID": getuid(), "processImagePath": "/Applications/Claude.app/Contents/MacOS/Claude",
                "subsystem": "com.apple.UserNotifications",
                "eventMessage": "[com.anthropic.claudefordesktop] Adding notification request 8DC1-3B6E to destinations: (\\n NotificationCenter,\\n LockScreen\\n), contentDate: (null)"
            ]
            for (key, value) in changes { record[key] = value }
            return String(data: try! JSONSerialization.data(withJSONObject: record), encoding: .utf8)!
        }
        let attention = claude.consume(native(), now: now)
        precondition(attention?.source == "claude" && attention?.kind == "attention")
        precondition(claude.consume(native(), now: now) == nil, "Suppress duplicate native record")
        precondition(claude.consume(native(["timestamp": nativeDate.string(from: now)]), now: now) != nil,
                     "Claude reuses tags: a later submission must still chime")
        precondition(claude.consume(native(["userID": getuid() + 1]), now: now) == nil, "Ignore other Mac users")
        precondition(claude.consume(native(["processImagePath": "/Applications/Other.app/Contents/MacOS/Other"]), now: now) == nil)
        precondition(claude.consume(native(["eventMessage": "[com.anthropic.claudefordesktop] Getting notification settings"]), now: now) == nil)
        precondition(claude.consume(native(["eventMessage": "[com.other.app] Adding notification request ABCD to destinations:"]), now: now) == nil)
        precondition(claude.consume(native(), now: start.addingTimeInterval(60)) == nil)
        precondition(ClaudeEventDetector(start: now).consume(native(), now: now) == nil)
        precondition(claude.consume("not JSON", now: now) == nil)

        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }
        let log = root.appendingPathComponent("codex-desktop-test.log")
        try Data("old event\n".utf8).write(to: log)
        let follower = LogFollower(root: root)
        precondition(follower.poll().isEmpty, "Start at EOF")
        func append(_ text: String) throws {
            let file = try FileHandle(forWritingTo: log)
            try file.seekToEnd(); try file.write(contentsOf: Data(text.utf8)); try file.close()
        }
        try append("partial")
        precondition(follower.poll().isEmpty)
        try append(" line\nsecond\n")
        precondition(follower.poll() == ["partial line", "second"], "Partial lines must survive polls")
        try Data("reset\n".utf8).write(to: log)
        precondition(follower.poll() == ["reset"], "Handle truncation")
        let rotated = root.appendingPathComponent("codex-desktop-new.log")
        try Data("new file\n".utf8).write(to: rotated)
        precondition(follower.poll() == ["new file"], "Handle new logs after startup")
        try FileManager.default.removeItem(at: log)
        try Data("replacement\n".utf8).write(to: log)
        precondition(follower.poll() == ["replacement"], "Handle inode replacement")
        print("PASS: Codex event types; Claude native metadata, reused tags, user/process filtering; duplicate/stale rejection; partial writes and log rotation")
    }
}
