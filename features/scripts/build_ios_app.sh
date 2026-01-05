#!/usr/bin/env bash
set -o errexit

# Use fvm if it is on the PATH
if [ `command -v fvm` ]; then
  FLUTTER_BIN="fvm flutter"
fi

if [ -z "$FLUTTER_BIN" ]; then
  FLUTTER_BIN="flutter"
fi

echo "Flutter Bin: $FLUTTER_BIN"

cd features/fixtures/app
$FLUTTER_BIN build ipa --export-options-plist=ios/exportOptions.plist --no-tree-shake-icons
