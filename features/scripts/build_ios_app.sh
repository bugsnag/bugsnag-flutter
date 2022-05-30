#!/usr/bin/env bash
set -o errexit

if [ -z "$FLUTTER_DIR" ]; then
  FLUTTER_DIR="flutter"
fi

cd features/fixtures/app
$FLUTTER_DIR build ipa --export-options-plist=ios/exportOptions.plist

mv ../../../features/fixtures/app/build/ios/ipa/app.ipa ../../../features/fixtures/app/build/ios/ipa/app-$FLUTTER_VERSION.ipa