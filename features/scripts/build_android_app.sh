#!/usr/bin/env bash
set -o errexit

if [ -z "$FLUTTER_DIR" ]; then
  FLUTTER_DIR="flutter"
fi

cd features/fixtures/app
$FLUTTER_DIR build apk

mv ../../../features/fixtures/app/build/app/outputs/flutter-apk/app-release.apk ../../../features/fixtures/app/build/app/outputs/flutter-apk/app-release-$FLUTTER_VERSION.apk