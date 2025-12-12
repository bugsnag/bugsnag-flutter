#!/usr/bin/env bash
set -o errexit


DART_LOCATION=features/fixtures/mazerunner/lib

BS_DART_LOCATION=features/fixture_resources

echo "Copy test fixture code"

rm -rf "$BS_DART_LOCATION/lib"

cp -r $DART_LOCATION $BS_DART_LOCATION