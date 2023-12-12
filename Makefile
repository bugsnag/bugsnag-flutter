FLUTTER_BIN?=flutter

all: format build lint test

.PHONY: clean build bump aar examples/flutter test format lint e2e_android_local e2e_ios_local

clean:
	cd packages/bugsnag_flutter && $(FLUTTER_BIN) clean --suppress-analytics
	cd packages/bugsnag_breadcrumbs_dart_io && $(FLUTTER_BIN) clean --suppress-analytics
	cd packages/bugsnag_breadcrumbs_http && $(FLUTTER_BIN) clean --suppress-analytics
	cd examples/flutter && $(FLUTTER_BIN) clean --suppress-analytics && \
			rm -rf .idea bugsnag_flutter_example.iml \
			       ios/{Pods,.symlinks,Podfile.lock} \
				   ios/{Runner.xcworkspace,Runner.xcodeproj,Runner.xcodeproj/project.xcworkspace}/xcuserdata \
				   android/{.idea,.gradle,gradlew,gradlew.bat,local.properties,bugsnag_flutter_example_android.iml}
	rm -rf staging

build: aar examples/flutter

bump: ## Bump the version numbers to $VERSION
ifeq ($(VERSION),)
	@$(error VERSION is not defined. Run with `make VERSION=number bump`)
endif
	sed -i '' "s/## TBD/## $(VERSION) ($(shell date '+%Y-%m-%d'))/" CHANGELOG.md
	sed -i '' "s/^version: .*/version: $(VERSION)/" packages/bugsnag_flutter/pubspec.yaml
	sed -i '' "s/^version: .*/version: $(VERSION)/" packages/bugsnag_breadcrumbs_dart_io/pubspec.yaml
	sed -i '' "s/^version: .*/version: $(VERSION)/" packages/bugsnag_breadcrumbs_http/pubspec.yaml
	sed -i '' "s/^  'version': .*/  'version': '$(VERSION)'/" packages/bugsnag_flutter/lib/src/client.dart

staging/bugsnag_flutter:
	mkdir -p staging/bugsnag_flutter
	cd packages/bugsnag_flutter && cp -a . ../../staging/bugsnag_flutter
	rm -f staging/bugsnag_flutter/pubspec.lock
	cp -r examples staging/bugsnag_flutter/examples
	cp README.md staging/bugsnag_flutter/.
	cp LICENSE staging/bugsnag_flutter/.
	cp CHANGELOG.md staging/bugsnag_flutter/.
	sed -i '' -e '1,2d' staging/bugsnag_flutter/CHANGELOG.md

BSG_FLUTTER_VERSION:=$(shell grep 'version: ' packages/bugsnag_flutter/pubspec.yaml | grep -o '[0-9].*')
staging/%:
	mkdir -p staging/$*
	cd packages/$* && cp -a . ../../staging/$*
	rm -f staging/$*/pubspec.lock
	cp LICENSE staging/$*/.
	cp CHANGELOG.md staging/$*/.
	sed -i '' -e '1,2d' staging/$*/CHANGELOG.md
	# Replace the path references to bugsnag_flutter with version-based references, and allow publishing (strip lines with 'publish_to: none')
	sed -i '' "s/^  bugsnag_flutter:.*/  bugsnag_flutter: ^$(BSG_FLUTTER_VERSION)/" staging/$*/pubspec.yaml
	sed -i '' "s/path:.*/ /;s/publish_to: none/ /" staging/$*/pubspec.yaml

stage: clean staging/bugsnag_flutter staging/bugsnag_breadcrumbs_dart_io staging/bugsnag_breadcrumbs_http

aar:
	cd packages/bugsnag_flutter && $(FLUTTER_BIN) build aar --suppress-analytics

examples/flutter:
	cd $@ && $(FLUTTER_BIN) pub get
	cd $@ && $(FLUTTER_BIN) build apk --suppress-analytics
	cd $@ && $(FLUTTER_BIN) build ios --no-codesign --suppress-analytics --no-tree-shake-icons

test:
	cd packages/bugsnag_flutter && $(FLUTTER_BIN) test -r expanded --suppress-analytics
	cd packages/bugsnag_breadcrumbs_http && $(FLUTTER_BIN) test -r expanded --suppress-analytics

test-fixtures: ## Build the end-to-end test fixtures
	@./features/scripts/build_ios_app.sh
	@./features/scripts/build_android_app.sh

format:
	$(FLUTTER_BIN) format packages/bugsnag_flutter example features/fixtures/app

lint:
	cd packages/bugsnag_flutter && $(FLUTTER_BIN) analyze --suppress-analytics
	cd packages/bugsnag_breadcrumbs_dart_io && $(FLUTTER_BIN) analyze --suppress-analytics
	cd packages/bugsnag_breadcrumbs_http && $(FLUTTER_BIN) analyze --suppress-analytics

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

update-bugsnag-android:
ifeq ($(VERSION),)
	@$(error VERSION is not defined. Run with `make VERSION=number update-bugsnag-android`)
endif
	sed -i '' "s/'com.bugsnag:bugsnag-android:.*'/'com.bugsnag:bugsnag-android:$(VERSION)'/" packages/bugsnag_flutter/android/build.gradle

update-bugsnag-cocoa:
ifeq ($(VERSION),)
	@$(error VERSION is not defined. Run with `make VERSION=number update-bugsnag-cocoa`)
endif
	sed -i '' "s/s.dependency 'Bugsnag', '.*'/s.dependency 'Bugsnag', '$(VERSION)'/" packages/bugsnag_flutter/ios/bugsnag_flutter.podspec

update-bugsnag-dependency:
ifeq ($(SUBMODULE),)
	@$(error SUBMODULE is not defined. Run with `make SUBMODULE=target update-bugsnag-dependency`)
endif
ifeq ($(SUBMODULE), bugsnag-android)
	$(MAKE) update-bugsnag-android
else ifeq ($(SUBMODULE), bugsnag-cocoa)
	$(MAKE) update-bugsnag-cocoa
else
	@$(error SUBMODULE must be one of bugsnag-android or bugsnag-cocoa)
endif