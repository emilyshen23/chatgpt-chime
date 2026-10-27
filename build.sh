#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"
APP="$PWD/build/ChatGPT Chime.app"
VERSION="$(cat VERSION)"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources" build/module-cache
/usr/bin/swiftc -module-cache-path "$PWD/build/module-cache" Sources/Core.swift Tests/Tests.swift -o build/chime-tests
build/chime-tests
SDK="$(/usr/bin/xcrun --sdk macosx --show-sdk-path)"
for ARCH in arm64 x86_64; do
    /usr/bin/swiftc -O -sdk "$SDK" -target "$ARCH-apple-macosx13.0" -module-cache-path "$PWD/build/module-cache" Sources/Core.swift Sources/ClaudeMonitor.swift Sources/main.swift -framework AppKit -o "build/DesktopChime-$ARCH"
done
/usr/bin/lipo -create build/DesktopChime-arm64 build/DesktopChime-x86_64 -output "$APP/Contents/MacOS/DesktopChime"
/usr/bin/python3 - "$APP" "$VERSION" <<'PY'
import math, pathlib, plistlib, struct, sys, wave
app = pathlib.Path(sys.argv[1])
info = dict(CFBundleIdentifier='io.github.emilyshen23.chatgpt-chime', CFBundleName='ChatGPT Chime',
    CFBundleDisplayName='ChatGPT Chime', CFBundleExecutable='DesktopChime',
    CFBundlePackageType='APPL', CFBundleShortVersionString=sys.argv[2], CFBundleVersion='1',
    LSUIElement=True, LSMinimumSystemVersion='13.0', NSHighResolutionCapable=True)
(app/'Contents/Info.plist').write_bytes(plistlib.dumps(info))
# Original synthesized chimes: a rounded sine bell, gentle attack, long decay.
for name, notes in [('calm-ready', [(0, 523.25), (.22, 783.99)]),
                    ('calm-input', [(0, 587.33), (.22, 739.99), (.44, 880)])]:
    rate = 44100
    frames = bytearray()
    for i in range(int(rate * 1.8)):
        t = i / rate
        value = 0.0
        for onset, hz in notes:
            u = t - onset
            if u >= 0:
                env = (1 - math.exp(-u / .018)) * math.exp(-u / .34)
                value += .22 * env * (math.sin(2*math.pi*hz*u) + .12*math.sin(2*math.pi*hz*2*u))
        value *= min(1, (1.8-t)/.15)
        frames.extend(struct.pack('<h', int(max(-1, min(1, value)) * 32767)))
    with wave.open(str(app/'Contents/Resources'/f'{name}.wav'), 'wb') as out:
        out.setnchannels(1); out.setsampwidth(2); out.setframerate(rate); out.writeframes(frames)
PY
/usr/bin/codesign --force --sign - "$APP"
/usr/bin/codesign --verify --strict "$APP"
for ARCH in arm64 x86_64; do
    /usr/bin/lipo "$APP/Contents/MacOS/DesktopChime" -verify_arch "$ARCH"
done
echo "Built: $APP"
