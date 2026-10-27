#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"
/usr/bin/open "$PWD/build/ChatGPT Chime.app" --args --test-sound
