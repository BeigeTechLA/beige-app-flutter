#!/usr/bin/env bash
# Build dev-flavor release: iOS IPA then Android APK.
# Usage: ./scripts/build_dev.sh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

log() { printf "\n\033[1;34m==> %s\033[0m\n" "$*"; }
err() { printf "\n\033[1;31m!! %s\033[0m\n" "$*" >&2; }

log "flutter clean"
flutter clean

log "flutter pub get"
flutter pub get

log "Build iOS IPA (dev, release)"
if [[ "$(uname)" != "Darwin" ]]; then
  err "iOS build requires macOS. Skipping."
else
  flutter build ipa --flavor dev -t lib/main_dev.dart --release
fi

log "Build Android APK (dev, release)"
flutter build apk --flavor dev -t lib/main_dev.dart --release

log "Done"
echo "IPA: build/ios/ipa/*.ipa"
echo "APK: build/app/outputs/flutter-apk/app-dev-release.apk"