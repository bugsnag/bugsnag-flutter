Feature: Start Bugsnag from Flutter

  Scenario: Start Bugsnag and notify a handled exception
    Given I run "StartBugsnagScenario"
    And I wait to receive an error
    Then the error is valid for the error reporting API version "4.0" for the "Flutter Bugsnag Notifier" notifier with the apiKey "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
    And the error payload field "events.0.breadcrumbs" is an array with 0 elements
    And the error payload field "events.0.threads" is an array with 0 elements
    And the event "app.releaseStage" equals "testing"
    And the event "app.type" equals "test"
    And the event "app.version" equals "1.2.3"
    And the event "context" equals "awesome"
    And the event "metaData.custom.foo" equals "bar"
    And the event "metaData.custom.password" equals "not redacted"
    And the event "metaData.custom.secret" equals "[REDACTED]"
    And the exception "errorClass" equals "_Exception"
    And the event contains the following feature flags:
      | featureFlag  | variant |
      | demo-mode    |         |
      | sample-group | 123     |
    And on Android, the event "app.versionCode" equals 4321

    And on Android, the error payload field "events.0.projectPackages" is an array with 2 elements
    And on Android, the event "projectPackages.0" equals "MazeRunner"
    And on Android, the event "projectPackages.1" equals "com.bugsnag.flutter.test.app"
