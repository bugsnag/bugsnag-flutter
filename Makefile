all: build lint test

.PHONY: clean build aar example test lint e2e_ios_local

clean:
	cd bugsnag_flutter && flutter clean --suppress-analytics
	cd example && flutter clean --suppress-analytics

build: aar example

aar:
	cd bugsnag_flutter && flutter build aar --suppress-analytics

example:
	cd example && flutter build apk --suppress-analytics && flutter build ios --no-codesign --suppress-analytics

test:
	cd bugsnag_flutter && flutter test -r expanded --suppress-analytics

test-fixtures: ## Build the end-to-end test fixtures
	@./features/scripts/build_ios_app.sh
	@./features/scripts/build_android_app.sh

lint:
	cd bugsnag_flutter && flutter analyze --suppress-analytics

e2e_ios_local: features/fixtures/app/build/ios/ipa/app.ipa
	ideviceinstaller --uninstall com.bugsnag.flutter.test.app
	bundle exec maze-runner --app=$< --farm=local --os=ios --os-version=15 --apple-team-id=372ZUL2ZB7 --udid="$(shell idevice_id -l)" $(FEATURES)

features/fixtures/app/build/ios/ipa/app.ipa: $(shell find bugsnag_flutter features/fixtures/app/ios/Runner features/fixtures/app/lib -type f)
	cd features/fixtures/app && flutter build ipa --export-options-plist=ios/exportOptions.plist
