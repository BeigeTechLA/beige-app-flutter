#!/usr/bin/env bash
# Build prod-flavor release: iOS IPA then Android APK.
# Usage: ./scripts/build_prod.sh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

log() { printf "\n\033[1;34m==> %s\033[0m\n" "$*"; }
err() { printf "\n\033[1;31m!! %s\033[0m\n" "$*" >&2; }

log "flutter clean"
flutter clean

log "flutter pub get"
flutter pub get

log "Build iOS IPA (prod, release)"
if [[ "$(uname)" != "Darwin" ]]; then
  err "iOS build requires macOS. Skipping."
else
  flutter build ipa --flavor prod -t lib/main_prod.dart --release
fi

log "Build Android APK (prod, release)"
flutter build apk --flavor prod -t lib/main_prod.dart --release

log "Done"
echo "IPA: build/ios/ipa/*.ipa"
echo "APK: build/app/outputs/flutter-apk/app-prod-release.apk"
