#!/usr/bin/env bash
set -o errexit

cd features/fixtures/app
flutter-$FLUTTER_VERSION build ipa --export-options-plist=ios/exportOptions.plist

mv ../../../features/fixtures/app/build/ios/ipa/app.ipa ../../../features/fixtures/app/build/ios/ipa/app-$FLUTTER_VERSION.ipa