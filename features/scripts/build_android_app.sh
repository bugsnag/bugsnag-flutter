#!/usr/bin/env bash
set -o errexit

if [ -z "$FLUTTER_DIR" ]; then
  FLUTTER_DIR="flutter"
fi

cd features/fixtures/app
$FLUTTER_DIR build apk
