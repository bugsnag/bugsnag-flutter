Feature: projectPackages

  Scenario: Sends projectPackages with events
    When I run "ProjectPackagesScenario"
    Then I wait to receive an error
    And the error is valid for the error reporting API version "4.0" for the "Flutter Bugsnag Notifier" notifier
    And the exception "errorClass" equals "_Exception"
    And the event "severity" equals "warning"
    And on iOS, the error payload field "events.0.projectPackages" is an array with 1 elements
    And on Android, the error payload field "events.0.projectPackages" is an array with 2 elements
    And the event "projectPackages.0" equals "app"
    And on Android, the event "projectPackages.1" equals "com.bugsnag.flutter.test.app"
