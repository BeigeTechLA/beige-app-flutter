.PHONY: build-dev build-dev-ios build-dev-android build-prod build-prod-ios build-prod-android clean pub

build-dev:
	./scripts/build_dev.sh

build-dev-ios:
	flutter clean && flutter pub get && flutter build ipa --flavor dev -t lib/main_dev.dart --release

build-dev-android:
	flutter clean && flutter pub get && flutter build apk --flavor dev -t lib/main_dev.dart --release

build-prod:
	./scripts/build_prod.sh

build-prod-ios:
	flutter clean && flutter pub get && flutter build ipa --flavor prod -t lib/main_prod.dart --release

build-prod-android:
	flutter clean && flutter pub get && flutter build apk --flavor prod -t lib/main_prod.dart --release

clean:
	flutter clean

pub:
	flutter pub get
