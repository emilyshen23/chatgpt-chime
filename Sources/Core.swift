import Foundation

struct ChimeEvent {
    let kind: String
    let key: String
    let date: Date
    var source: String = "codex"
}

// Claude does not expose completion/input categories in its public local logs.
// Observe only its native notification-submission metadata. This deliberately
// makes no inference from message text or from generic idle/background logs.
final class ClaudeEventDetector {
    private let start: Date
    private var seen: [String: Date] = [:]
    private let dates = DateFormatter()
    init(start: Date = Date()) {
        self.start = start
        dates.locale = Locale(identifier: "en_US_POSIX")
        dates.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSSZ"
    }
    func consume(_ line: String, now: Date = Date()) -> ChimeEvent? {
        guard let data = line.data(using: .utf8),
              let record = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              record["subsystem"] as? String == "com.apple.UserNotifications",
              let process = record["processImagePath"] as? String,
              process.hasSuffix("/Claude.app/Contents/MacOS/Claude"),
              let user = record["userID"] as? NSNumber, user.uint32Value == getuid(),
              let message = record["eventMessage"] as? String,
              message.hasPrefix("[com.anthropic.claudefordesktop] Adding notification request "),
              let token = message.range(of: #"Adding notification request [A-Za-z0-9_-]+ to destinations:"#, options: .regularExpression),
              let stamp = record["timestamp"] as? String, let date = dates.date(from: stamp),
              date >= start, now.timeIntervalSince(date) < 30, date.timeIntervalSince(now) < 5 else { return nil }
        // Claude reuses notification identifiers across turns. Deduplicate a
        // single submission, not all future submissions with the same tag.
        let key = "claude:" + String(message[token]) + ":" + stamp
        seen = seen.filter { now.timeIntervalSince($0.value) < 3600 }
        guard seen[key] == nil else { return nil }
        seen[key] = now
        return ChimeEvent(kind: "attention", key: key, date: date, source: "claude")
    }
}

// Use only the final notification delivery record, not the duplicate renderer
// and forwarding records. Never inspect prompt or response content.
final class EventDetector {
    private let start: Date
    private var seen: [String: Date] = [:]
    private let dates = ISO8601DateFormatter()
    init(start: Date = Date()) {
        self.start = start
        dates.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    }
    func consume(_ line: String, now: Date = Date()) -> ChimeEvent? {
        guard line.contains("info [desktop-notifications] show notification "),
              let kindRange = line.range(of: #"\bkind=(turn-complete|permission|question)\b"#, options: .regularExpression),
              let idRange = line.range(of: " notificationId="),
              let stamp = line.split(separator: " ").first,
              let date = dates.date(from: String(stamp)),
              date >= start, now.timeIntervalSince(date) < 30,
              date.timeIntervalSince(now) < 5 else { return nil }
        let kind = String(line[kindRange]).replacingOccurrences(of: "kind=", with: "")
        let identifier = String(line[idRange.upperBound...]).trimmingCharacters(in: .whitespacesAndNewlines)
        guard !identifier.isEmpty, identifier != "undefined" else { return nil }
        let key = kind + ":" + identifier
        seen = seen.filter { now.timeIntervalSince($0.value) < 3600 }
        guard seen[key] == nil else { return nil }
        seen[key] = now
        return ChimeEvent(kind: kind, key: key, date: date)
    }
}

final class LogFollower {
    struct Cursor {
        var inode: UInt64
        var offset: UInt64
        var pending = Data()
    }
    let root: URL
    private var cursors: [URL: Cursor] = [:]
    private(set) var fileCount = 0
    private(set) var error: String?
    init(root: URL) { self.root = root; scan(initial: true) }
    private func files() -> [URL] {
        var result: [URL] = []
        error = nil
        guard let walk = FileManager.default.enumerator(at: root, includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles], errorHandler: { _, _ in self.error = "Cannot read app logs"; return true }) else {
            error = "Waiting for app logs"; return []
        }
        for case let url as URL in walk where url.pathExtension == "log" && url.lastPathComponent.hasPrefix("codex-desktop-") {
            result.append(url)
        }
        if result.isEmpty && error == nil { error = "Waiting for app logs" }
        return result
    }
    private func scan(initial: Bool) {
        let list = files()
        fileCount = list.count
        let active = Set(list)
        cursors = cursors.filter { active.contains($0.key) }
        for url in list {
            guard let a = try? FileManager.default.attributesOfItem(atPath: url.path),
                  let number = a[.systemFileNumber] as? NSNumber,
                  let size = a[.size] as? NSNumber else { continue }
            let inode = number.uint64Value
            if cursors[url] == nil || cursors[url]!.inode != inode {
                cursors[url] = Cursor(inode: inode, offset: initial ? size.uint64Value : 0)
            } else if size.uint64Value < cursors[url]!.offset {
                cursors[url] = Cursor(inode: inode, offset: 0)
            }
        }
    }
    func poll() -> [String] {
        scan(initial: false)
        var lines: [String] = []
        for url in Array(cursors.keys) {
            guard var cursor = cursors[url], let file = try? FileHandle(forReadingFrom: url) else { continue }
            defer { try? file.close() }
            do {
                try file.seek(toOffset: cursor.offset)
                let chunk = try file.read(upToCount: 1_048_576) ?? Data()
                cursor.offset += UInt64(chunk.count)
                cursor.pending.append(chunk)
                if let lastNewline = cursor.pending.lastIndex(of: 10) {
                    let complete = cursor.pending.prefix(through: lastNewline)
                    lines += String(decoding: complete, as: UTF8.self).split(separator: "\n").map(String.init)
                    cursor.pending = Data(cursor.pending.suffix(from: lastNewline + 1))
                }
                if cursor.pending.count > 65_536 { cursor.pending.removeAll() }
                cursors[url] = cursor
            } catch { self.error = "Cannot read app logs" }
        }
        return lines
    }
}
