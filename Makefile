FLUTTER_BIN?=flutter

all: format build lint test

.PHONY: clean build bump aar example test format lint e2e_android_local e2e_ios_local

clean:
	cd packages/bugsnag_flutter && $(FLUTTER_BIN) clean --suppress-analytics
	cd packages/bugsnag_flutter_http && $(FLUTTER_BIN) clean --suppress-analytics
	cd example && $(FLUTTER_BIN) clean --suppress-analytics && \
			rm -rf .idea bugsnag_flutter_example.iml \
			       ios/{Pods,.symlinks,Podfile.lock} \
				   ios/{Runner.xcworkspace,Runner.xcodeproj,Runner.xcodeproj/project.xcworkspace}/xcuserdata \
				   android/{.idea,.gradle,gradlew,gradlew.bat,local.properties,bugsnag_flutter_example_android.iml}
	rm -rf staging

build: aar example

bump: ## Bump the version numbers to $VERSION
ifeq ($(VERSION),)
	@$(error VERSION is not defined. Run with `make VERSION=number bump`)
endif
	sed -i '' "s/## TBD/## $(VERSION) ($(shell date '+%Y-%m-%d'))/" CHANGELOG.md
	sed -i '' "s/^version: .*/version: $(VERSION)/" packages/bugsnag_flutter/pubspec.yaml
	sed -i '' "s/^version: .*/version: $(VERSION)/" packages/bugsnag_flutter_http/pubspec.yaml
	sed -i '' "s/^  'version': .*/  'version': '$(VERSION)'/" packages/bugsnag_flutter/lib/src/client.dart

stage: clean
	mkdir staging
	cd packages/bugsnag_flutter && cp -a . ../../staging/
	rm -f staging/pubspec.lock
	cp -r example staging/example
	cp README.md staging/.
	cp LICENSE staging/.
	cp CHANGELOG.md staging/.
	sed -i '' -e '1,2d' staging/CHANGELOG.md

aar:
	cd packages/bugsnag_flutter && $(FLUTTER_BIN) build aar --suppress-analytics

example:
	cd example &&  $(FLUTTER_BIN) build apk --suppress-analytics &&  $(FLUTTER_BIN) build ios --no-codesign --suppress-analytics

test:
	cd packages/bugsnag_flutter && $(FLUTTER_BIN) test -r expanded --suppress-analytics
	cd packages/bugsnag_flutter_http && $(FLUTTER_BIN) test -r expanded --suppress-analytics

test-fixtures: ## Build the end-to-end test fixtures
	@./features/scripts/build_ios_app.sh
	@./features/scripts/build_android_app.sh

format:
	$(FLUTTER_BIN) format packages/bugsnag_flutter example features/fixtures/app

lint:
	cd packages/bugsnag_flutter && $(FLUTTER_BIN) analyze --suppress-analytics
	cd packages/bugsnag_flutter_http && $(FLUTTER_BIN) analyze --suppress-analytics

e2e_android_local: features/fixtures/app/build/app/outputs/flutter-apk/app-release.apk
	$(HOME)/Library/Android/sdk/platform-tools/adb uninstall com.bugsnag.flutter.test.app || true
	bundle exec maze-runner --app=$< --farm=local --os=android --os-version=10 $(FEATURES)

features/fixtures/app/build/app/outputs/flutter-apk/app-release.apk: $(shell find packages/bugsnag_flutter features/fixtures/app/android/app/src features/fixtures/app/lib -type f)
	cd features/fixtures/app && $(FLUTTER_BIN) build apk

e2e_ios_local: features/fixtures/app/build/ios/ipa/app.ipa
	ideviceinstaller --uninstall com.bugsnag.flutter.test.app
	bundle exec maze-runner --app=$< --farm=local --os=ios --os-version=15 --apple-team-id=372ZUL2ZB7 --udid="$(shell idevice_id -l)" $(FEATURES)

features/fixtures/app/build/ios/ipa/app.ipa: $(shell find packages/bugsnag_flutter features/fixtures/app/ios/Runner features/fixtures/app/lib -type f)
	cd features/fixtures/app && $(FLUTTER_BIN) build ipa --export-options-plist=ios/exportOptions.plist
