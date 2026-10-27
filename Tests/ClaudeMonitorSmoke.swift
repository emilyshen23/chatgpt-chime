import Foundation

// Optional integration check on a logged-in Mac. This verifies the native log
// stream can stay running as the current user, not that Claude emitted an event.
@main struct ClaudeMonitorSmoke {
    static func main() {
        let monitor = ClaudeMonitor()
        monitor.onStatus = { print($0) }
        monitor.start()
        RunLoop.current.run(until: Date().addingTimeInterval(3))
        let alive = monitor.running
        monitor.stop()
        if !alive { fputs("FAIL: Claude log stream exited or could not start\n", stderr); exit(1) }
        print("PASS: native Claude monitor stays running; explicit stop succeeds")
    }
}
