#!/usr/bin/env bash
set -o errexit

cd features/fixtures/app
flutter build ipa --export-options-plist=ios/exportOptions.plist
