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
  s.source_files        = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.platform            = :ios, '9.0'
  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }

  s.dependency 'Flutter'
  s.dependency 'Bugsnag', '6.25.3'
end
