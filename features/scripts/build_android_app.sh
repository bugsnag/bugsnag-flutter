#!/usr/bin/env bash
set -o errexit

cd features/fixtures/app
flutter build apk
