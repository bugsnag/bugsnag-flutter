Pod::Spec.new do |s|
  s.name                = 'bugsnag_flutter'
  s.version             = '0.0.1'
  s.summary             = 'Bugsnag crash monitoring and reporting tool for Flutter apps'
  s.description         = <<-DESC
Bugsnag crash monitoring and reporting tool for Flutter apps
                       DESC
  s.homepage            = 'https://www.bugsnag.com'
  s.license             = 'MIT'
  s.author              = { 'Bugsnag' => 'notifiers@bugsnag.com' }
  s.source              = { :path => '.' }
  s.source_files        = 'bugsnag_flutter/Sources/bugsnag_flutter/**/*.{h,m}'
  s.public_header_files = 'bugsnag_flutter/Sources/bugsnag_flutter/include/**/*.h'
  s.exclude_files       = 'bugsnag_flutter/Sources/bugsnag_flutter/BugsnagFlutterInternals.h'
  s.header_mappings_dir = 'bugsnag_flutter/Sources/bugsnag_flutter/include'
  s.resource_bundles    = {'bugsnag_flutter_privacy' => ['bugsnag_flutter/Sources/bugsnag_flutter/PrivacyInfo.xcprivacy']}
  s.platform            = :ios, '12.0'
  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }

  s.dependency 'Flutter'
  s.dependency 'Bugsnag', '6.38.0'
end
