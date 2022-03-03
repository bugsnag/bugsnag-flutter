all: build lint test

.PHONY: clean build aar example test lint

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

lint: aar
	cd bugsnag_flutter && flutter analyze --suppress-analytics
	cd bugsnag_flutter/android && ./gradlew \
		-x compileDebugSources -x compileProfileSources -x compileReleaseSources \
		-x compileDebugJavaWithJavac -x compileProfileJavaWithJavac -x compileReleaseJavaWithJavac \
		lint
