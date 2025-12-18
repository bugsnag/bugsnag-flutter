#!/usr/bin/env bash
set -o errexit
set -o pipefail
set -o nounset

if [[ -z "${FLUTTER_BIN:-}" ]]; then
  FLUTTER_BIN="flutter"
  echo "FLUTTER_BIN not set; defaulting to 'flutter'"
fi

echo "--- 📦 Bundle Install"
if ! bundle install; then
  echo "Warning: bundle install failed but continuing"
fi

echo "--- ☁️ Updating CocoaPods"
if ! pod repo update trunk; then
  echo "Warning: pod repo update trunk failed but continuing"
fi

echo "--- 🔧 Generate Fixture"
echo "Running generate_fixture.sh script"
./features/scripts/generate_fixture.sh

echo "--- 🚧 Running xcodebuild to set provisioning profile (failure allowed)..."
EXPORT_OPTIONS="$(pwd)/features/fixture_resources/exportOptions.plist"
echo "Using export options plist at: \"$EXPORT_OPTIONS\""

IOS_DIR="features/fixtures/mazerunner/ios"
echo "Changing directory to \"$IOS_DIR\""
cd "$IOS_DIR"

xcodebuild build \
  -workspace "./Runner.xcworkspace" \
  -scheme "Runner" \
  -configuration "Release" \
  -allowProvisioningUpdates | tee xcodebuild.log || echo "xcodebuild failed but continuing as expected"

echo "--- 🚀 Building Flutter IPA"
echo "Running flutter build ipa command"
"$FLUTTER_BIN" build ipa \
  --export-options-plist="$EXPORT_OPTIONS" \
  --no-tree-shake-icons
