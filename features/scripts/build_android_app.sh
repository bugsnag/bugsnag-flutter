#!/usr/bin/env bash
set -o errexit

if [ -z "$FLUTTER_BIN" ]; then
  FLUTTER_BIN="flutter"
fi

echo "Flutter Bin: $FLUTTER_BIN"

cd features/fixtures/app
$FLUTTER_BIN build apk --no-tree-shake-icons
