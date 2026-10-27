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
        print("PASS: completion, permission, question, duplicate suppression, stale rejection, partial writes, truncation, new files and replacement")
    }
}
