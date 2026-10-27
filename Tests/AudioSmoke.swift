import AppKit

final class PlaybackResult: NSObject, NSSoundDelegate {
    var finished = false
    var success = false
    func sound(_ sound: NSSound, didFinishPlaying flag: Bool) {
        finished = true; success = flag
    }
}

/// Optional integration test: run outside a terminal sandbox on a logged-in
/// Mac. It audibly plays both packaged chimes, without changing output volume.
@main struct AudioSmoke {
    static func main() {
        guard CommandLine.arguments.count == 2 else {
            fputs("Usage: audio-smoke /path/to/ChatGPT Chime.app\n", stderr); exit(1)
        }
        let root = URL(fileURLWithPath: CommandLine.arguments[1]).appendingPathComponent("Contents/Resources")
        for name in ["calm-ready", "calm-input"] {
            let file = root.appendingPathComponent(name + ".wav")
            guard let sound = NSSound(contentsOf: file, byReference: false) else {
                fputs("FAIL: cannot load packaged chime\n", stderr); exit(1)
            }
            let result = PlaybackResult()
            sound.delegate = result; sound.volume = 0.65
            guard sound.play() else { fputs("FAIL: playback rejected\n", stderr); exit(1) }
            let end = Date().addingTimeInterval(5)
            while !result.finished && Date() < end {
                RunLoop.current.run(until: Date().addingTimeInterval(0.05))
            }
            guard result.finished && result.success else {
                fputs("FAIL: audio did not finish successfully\n", stderr); exit(1)
            }
            print("PASS: \(name) loaded, started, and completed playback")
        }
    }
}
