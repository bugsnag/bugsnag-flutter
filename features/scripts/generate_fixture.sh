#!/usr/bin/env bash
set -o errexit
set -o pipefail
set -o nounset

if [[ -z "${FLUTTER_BIN:-}" ]]; then
  FLUTTER_BIN="flutter"
  echo "FLUTTER_BIN not set; defaulting to 'flutter'"
fi

FIXTURE_NAME="maze_runner"

FIXTURE_LOCATION="features/fixtures/$FIXTURE_NAME"

PACKAGE_PATH="$(pwd)/packages/bugsnag_flutter"

HTTP_WRAPPER_PACKAGE_PATH="$(pwd)/packages/bugsnag_http_client"

DART_IO_WRAPPER_PACKAGE_PATH="$(pwd)/packages/bugsnag_flutter_dart_io_http_client"

EXPORT_OPTIONS="features/fixture_resources/exportOptions.plist"

XCODE_PROJECT="features/fixtures/$FIXTURE_NAME/ios/Runner.xcodeproj/project.pbxproj"

XCODE_PLIST="features/fixtures/$FIXTURE_NAME/ios/Runner/Info.plist"

ANDROID_MANIFEST="features/fixtures/$FIXTURE_NAME/android/app/src/main/AndroidManifest.xml"

DART_LOCATION="features/fixtures/$FIXTURE_NAME/lib"

DART_TEST_LOCATION="features/fixtures/test"

BS_DART_LOCATION="features/fixture_resources/lib"

BS_DART_DESTINATION="features/fixtures/$FIXTURE_NAME"

# Change android gradle file based on flutter version
if $FLUTTER_BIN --version | grep -qE 'Flutter 3\.(3[8-9]|[4-9][0-9]|[1-9][0-9]{2,})'; then
  ANDROID_GRADLE="features/fixtures/$FIXTURE_NAME/android/app/build.gradle.kts"
else
  ANDROID_GRADLE="features/fixtures/$FIXTURE_NAME/android/app/build.gradle"
fi

PODFILE="features/fixtures/$FIXTURE_NAME/ios/Podfile"

echo "--- Removing old fixture"

rm -rf "$FIXTURE_LOCATION"

echo "--- Creating new Flutter fixture"

"$FLUTTER_BIN" create "$FIXTURE_LOCATION"  --org com.bugsnag --platforms=ios,android

echo "--- Adding dependencies"

$FLUTTER_BIN pub add --directory="$FIXTURE_LOCATION" "bugsnag_flutter:{'path':'$PACKAGE_PATH'}"

$FLUTTER_BIN pub add --directory="$FIXTURE_LOCATION" path_provider

$FLUTTER_BIN pub add --directory="$FIXTURE_LOCATION" http

# Change the version of native_flutter_proxy based on flutter version. >= 3.20.0 requires a newer version
if $FLUTTER_BIN --version | grep -qE 'Flutter 3\.(2[0-9]|[3-9][0-9]|[1-9][0-9]{2,})'; then
  $FLUTTER_BIN pub add --directory="$FIXTURE_LOCATION" "native_flutter_proxy"
  sed -i '' "s|import 'package:native_flutter_proxy/custom_proxy.dart';|import 'package:native_flutter_proxy/src/custom_proxy.dart';|" "${BS_DART_LOCATION}/main.dart"
  sed -i '' "s|import 'package:native_flutter_proxy/native_proxy_reader.dart';|import 'package:native_flutter_proxy/src/native_proxy_reader.dart';|" "${BS_DART_LOCATION}/main.dart"
else
  $FLUTTER_BIN pub add --directory="$FIXTURE_LOCATION" "native_flutter_proxy:0.1.15"
fi

$FLUTTER_BIN pub add --directory="$FIXTURE_LOCATION" "bugsnag_http_client:{'path':'$HTTP_WRAPPER_PACKAGE_PATH'}"
$FLUTTER_BIN pub add --directory="$FIXTURE_LOCATION" "bugsnag_flutter_dart_io_http_client:{'path':'$DART_IO_WRAPPER_PACKAGE_PATH'}"

$FLUTTER_BIN pub add --directory="$FIXTURE_LOCATION" dio

echo "--- Updating Android Gradle file"

sed -i '' 's/minSdkVersion flutter.minSdkVersion/minSdkVersion 19/g' "$ANDROID_GRADLE"

echo "--- Updating iOS Podfile"

sed -i '' "s/# platform :ios, '11.0'/platform :ios, '12.0'/" "$PODFILE"

echo "--- Updating Xcode project"

sed -i '' "s/ENABLE_BITCODE = NO;/ENABLE_BITCODE = NO;\nDEVELOPMENT_TEAM = 7W9PZ27Y5F;\nCODE_SIGN_STYLE = Automatic;/g" "$XCODE_PROJECT"

echo "--- Updating Xcode plist"

sed -i '' "s/<key>CFBundleDevelopmentRegion<\/key>/<key>NSAppTransportSecurity<\/key><dict><key>NSAllowsArbitraryLoads<\/key><true\/><\/dict>\n<key>CFBundleDevelopmentRegion<\/key>/g" "$XCODE_PLIST"

echo "--- Updating Android Manifest"

sed -i '' "s|</application>|</application>\n<uses-permission android:name='android.permission.INTERNET'/>|g" "$ANDROID_MANIFEST"

sed -i '' "s|android:icon=\"@mipmap/ic_launcher\">|android:icon=\"@mipmap/ic_launcher\"\n        android:usesCleartextTraffic=\"true\">|g" "$ANDROID_MANIFEST"

echo "--- Copying test fixture code"

rm -rf "$DART_TEST_LOCATION"

rm -rf "$DART_LOCATION"

cp -r "$BS_DART_LOCATION" "$BS_DART_DESTINATION"
