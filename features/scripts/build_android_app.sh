#!/usr/bin/env bash
set -o errexit

cd features/fixtures/app
flutter-$FLUTTER_VERSION build apk

mv ../../../features/fixtures/app/build/app/outputs/flutter-apk/app-release.apk ../../../features/fixtures/app/build/app/outputs/flutter-apk/app-release-$FLUTTER_VERSION.apk