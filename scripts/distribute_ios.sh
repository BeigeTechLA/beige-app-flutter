#!/usr/bin/env bash
#
# Distribute iOS IPA to TestFlight (App Store Connect).
#
# Usage:
#   ./scripts/distribute_ios.sh dev
#   ./scripts/distribute_ios.sh prod
#
# Prereqs:
#   - macOS with Xcode installed + signed in to Apple Developer account
#   - flutter on PATH
#   - Provisioning profile + signing cert configured in Xcode (Runner target)
#     Distribution method: App Store (required for TestFlight)
#   - Environment variables set:
#       APPLE_ID            Apple Developer account email
#       APPLE_APP_PASSWORD  App-specific password (https://appleid.apple.com -> Sign-In and Security -> App-Specific Passwords)
#
#   Export to shell before running, e.g.:
#       export APPLE_ID="you@example.com"
#       export APPLE_APP_PASSWORD="abcd-efgh-ijkl-mnop"
#
# Notes:
#   - Release notes / "What to Test" set manually in App Store Connect UI after upload.
#   - dev and prod must be separate App Store Connect apps (different bundle IDs).

set -euo pipefail

ENV="${1:-}"

if [[ "$ENV" != "dev" && "$ENV" != "prod" ]]; then
  echo "Error: first arg must be 'dev' or 'prod'."
  echo "Usage: $0 dev|prod"
  exit 1
fi

if [[ -z "${APPLE_ID:-}" || -z "${APPLE_APP_PASSWORD:-}" ]]; then
  echo "Error: APPLE_ID and APPLE_APP_PASSWORD env vars must be set."
  echo "  export APPLE_ID=\"you@example.com\""
  echo "  export APPLE_APP_PASSWORD=\"xxxx-xxxx-xxxx-xxxx\""
  exit 1
fi

if [[ "$ENV" == "dev" ]]; then
  ENTRYPOINT="lib/main_dev.dart"
else
  ENTRYPOINT="lib/main_prod.dart"
fi

IPA_DIR="build/ios/ipa"

echo ">> [1/5] flutter clean"
flutter clean

echo ">> [2/5] flutter pub get"
flutter pub get

echo ">> [3/5] cd ios && pod install"
(cd ios && pod install)

echo ">> [4/5] flutter build ipa --flavor ${ENV} --release -t ${ENTRYPOINT} --export-method app-store"
flutter build ipa --flavor "$ENV" -t "$ENTRYPOINT" --release --export-method app-store

IPA_PATH="$(ls -t "$IPA_DIR"/*.ipa 2>/dev/null | head -1 || true)"

if [[ -z "$IPA_PATH" || ! -f "$IPA_PATH" ]]; then
  echo "Error: no IPA found in $IPA_DIR"
  echo "Open Xcode > Runner target > Signing & Capabilities. Verify team + provisioning profile (App Store distribution)."
  exit 1
fi

echo ">> Found IPA: $IPA_PATH"

echo ">> [5/5] xcrun altool --upload-app -f $IPA_PATH -t ios"
xcrun altool --upload-app \
  -f "$IPA_PATH" \
  -t ios \
  -u "$APPLE_ID" \
  -p "$APPLE_APP_PASSWORD"

echo ">> Done. Uploaded ${ENV} IPA to App Store Connect. Processing takes 5-30 min before build shows in TestFlight."