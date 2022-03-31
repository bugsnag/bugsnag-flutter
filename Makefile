all: build lint test

.PHONY: clean build bump aar example test format lint e2e_android_local e2e_ios_local

clean:
	cd bugsnag_flutter && flutter clean --suppress-analytics
	cd example && flutter clean --suppress-analytics

build: aar example

bump: ## Bump the version numbers to $VERSION
ifeq ($(VERSION),)
	@$(error VERSION is not defined. Run with `make VERSION=number bump`)
endif
	sed -i '' "s/^version: .*/version: $(VERSION)/" bugsnag_flutter/pubspec.yaml
	sed -i '' "s/^  'version': .*/  'version': '$(VERSION)'/" bugsnag_flutter/lib/src/client.dart

aar:
	cd bugsnag_flutter && flutter build aar --suppress-analytics

example:
	cd example && flutter build apk --suppress-analytics && flutter build ios --no-codesign --suppress-analytics

test:
	cd bugsnag_flutter && flutter test -r expanded --suppress-analytics

test-fixtures: ## Build the end-to-end test fixtures
	@./features/scripts/build_ios_app.sh
	@./features/scripts/build_android_app.sh

format:
	flutter format bugsnag_flutter example features/fixtures/app

lint:
	cd bugsnag_flutter && flutter analyze --suppress-analytics

e2e_android_local: features/fixtures/app/build/app/outputs/flutter-apk/app-release.apk
	$(HOME)/Library/Android/sdk/platform-tools/adb uninstall com.bugsnag.flutter.test.app || true
	bundle exec maze-runner --app=$< --farm=local --os=android --os-version=10 $(FEATURES)

features/fixtures/app/build/app/outputs/flutter-apk/app-release.apk: $(shell find bugsnag_flutter features/fixtures/app/android/app/src features/fixtures/app/lib -type f)
	cd features/fixtures/app && flutter build apk

e2e_ios_local: features/fixtures/app/build/ios/ipa/app.ipa
	ideviceinstaller --uninstall com.bugsnag.flutter.test.app
	bundle exec maze-runner --app=$< --farm=local --os=ios --os-version=15 --apple-team-id=372ZUL2ZB7 --udid="$(shell idevice_id -l)" $(FEATURES)

features/fixtures/app/build/ios/ipa/app.ipa: $(shell find bugsnag_flutter features/fixtures/app/ios/Runner features/fixtures/app/lib -type f)
	cd features/fixtures/app && flutter build ipa --export-options-plist=ios/exportOptions.plist
