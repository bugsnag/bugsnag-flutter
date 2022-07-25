Feature: projectPackages

  Scenario: Sends projectPackages with events
    When I run "ProjectPackagesScenario"
    Then I wait to receive an error
    And the error is valid for the error reporting API version "4.0" for the "Flutter Bugsnag Notifier" notifier
    And the exception "errorClass" equals "_Exception"
    And the event "severity" equals "warning"
    And on iOS, the error payload field "events.0.projectPackages" is an array with 2 elements
    And on Android, the error payload field "events.0.projectPackages" is an array with 3 elements
    And the event "projectPackages.0" equals "test_package"
    And the event "projectPackages.1" equals "MazeRunner"
    And on Android, the event "projectPackages.2" equals "com.bugsnag.flutter.test.app"

  Scenario: Sends projectPackages after attaching to native layer
    When I run "NativeProjectPackagesScenario"
    Then I wait to receive an error
    And the error is valid for the error reporting API version "4.0" for the "Flutter Bugsnag Notifier" notifier
    And the exception "errorClass" equals "_Exception"
    And the exception "message" equals "Keep calm and carry on"
    And the error payload field "events.0.projectPackages" is an array with 3 elements
    And the event "projectPackages.0" equals "test_package"
    And the event "projectPackages.1" equals "MazeRunner"
    And the event "projectPackages.2" equals "com.bugsnag.flutter.test.app"
