#!/usr/bin/env bash
#
# Distribute Android APK to Firebase App Distribution.
#
# Usage:
#   ./scripts/distribute_android.sh dev   [optional release notes]
#   ./scripts/distribute_android.sh prod  [optional release notes]
#
# Prereqs:
#   - flutter on PATH
#   - firebase CLI installed (`npm i -g firebase-tools`) and logged in (`firebase login`)

set -euo pipefail

ENV="${1:-}"
RELEASE_NOTES="${2:-Build uploaded via distribute_android.sh}"

if [[ "$ENV" != "dev" && "$ENV" != "prod" ]]; then
  echo "Error: first arg must be 'dev' or 'prod'."
  echo "Usage: $0 dev|prod [release notes]"
  exit 1
fi

if [[ "$ENV" == "dev" ]]; then
  FIREBASE_APP_ID="1:901444143218:android:288993a14c036d48149aeb"
  ENTRYPOINT="lib/main_dev.dart"
else
  FIREBASE_APP_ID="1:628292955928:android:4d5a7ca1be34e6754d786d"
  ENTRYPOINT="lib/main_prod.dart"
fi

APK_PATH="build/app/outputs/flutter-apk/app-${ENV}-release.apk"

echo ">> [1/3] flutter clean"
flutter clean

echo ">> [1.5/3] flutter pub get"
flutter pub get

echo ">> [2/3] flutter build apk --flavor ${ENV} --release -t ${ENTRYPOINT}"
flutter build apk --flavor "$ENV" -t "$ENTRYPOINT" --release

if [[ ! -f "$APK_PATH" ]]; then
  echo "Error: APK not found at $APK_PATH"
  exit 1
fi

echo ">> [3/3] firebase appdistribution:distribute $APK_PATH --app $FIREBASE_APP_ID"
firebase appdistribution:distribute "$APK_PATH" \
  --app "$FIREBASE_APP_ID" \
  --release-notes "$RELEASE_NOTES"

echo ">> Done. Uploaded ${ENV} APK to Firebase App Distribution."