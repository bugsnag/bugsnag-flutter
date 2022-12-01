Feature: Attach to running native Bugsnag instance

  Scenario: attach with a handled exception
    When I configure the app to run in the "handled" state
    And I run "AttachBugsnagScenario"
    Then I wait to receive an error
    And the error is valid for the error reporting API version "4.0" for the "Flutter Bugsnag Notifier" notifier
    And the exception "errorClass" equals "_Exception"
    And the exception "message" equals "Handled exception with attached info"
    And the error payload field "events.0.unhandled" is false
    And the error payload field "events.0.threads" is a non-empty array
    And the event "severity" equals "warning"

    And the event "user.id" equals "test-user-id"
    And the event "user.email" is null
    And the event "user.name" equals "Old Man Tables"

    And the event "context" equals "flutter-test-context"
    And event 0 contains the feature flag "demo-mode" with no variant
    And event 0 contains the feature flag "sample-group" with variant "123"

  Scenario: attach with an unhandled exception
    When I run "AttachBugsnagScenario"
    Then I wait to receive an error
    And the error is valid for the error reporting API version "4.0" for the "Flutter Bugsnag Notifier" notifier
    And the exception "errorClass" equals "_Exception"
    And the exception "message" equals "Unhandled exception with attached info"
    And the error payload field "events.0.threads" is a non-empty array
    And the event "context" equals "flutter-test-context"
    And the event "severity" equals "error"
    And the event "unhandled" is true
    And the event "user.email" is null
    And the event "user.id" equals "test-user-id"
    And the event "user.name" equals "Old Man Tables"
    And event 0 contains the feature flag "demo-mode" with no variant
    And event 0 contains the feature flag "sample-group" with variant "123"

  Scenario: attach with Dart error detection disabled
    When I configure the app to run in the "disableDartErrors" state
    And I run "AttachBugsnagScenario"
    Then I should receive no errors

  Scenario: multiple attaches with a handled exception
    When I configure the app to run in the "handled extra-attach" state
    And I run "AttachBugsnagScenario"
    Then I wait to receive 2 errors
    And the error is valid for the error reporting API version "4.0" for the "Flutter Bugsnag Notifier" notifier
    And the exception "errorClass" equals "_Exception"
    And the exception "message" equals "Handled exception with attached info"
    And the error payload field "events.0.unhandled" is false
    And the error payload field "events.0.threads" is a non-empty array
    And the event "severity" equals "warning"

    And the event "user.id" equals "test-user-id"
    And the event "user.email" is null
    And the event "user.name" equals "Old Man Tables"

    And the event "context" equals "flutter-test-context"
    And event 0 contains the feature flag "demo-mode" with no variant
    And event 0 contains the feature flag "sample-group" with variant "123"

  Scenario: multiple attaches with an unhandled exception
    When I configure the app to run in the "extra-attach" state
    When I run "AttachBugsnagScenario"
    Then I wait to receive 2 errors
    And the error is valid for the error reporting API version "4.0" for the "Flutter Bugsnag Notifier" notifier
    And the exception "errorClass" equals "_Exception"
    And the exception "message" equals "Unhandled exception with attached info"
    And the error payload field "events.0.threads" is a non-empty array
    And the event "context" equals "flutter-test-context"
    And the event "severity" equals "error"
    And the event "unhandled" is true
    And the event "user.email" is null
    And the event "user.id" equals "test-user-id"
    And the event "user.name" equals "Old Man Tables"
    And event 0 contains the feature flag "demo-mode" with no variant
    And event 0 contains the feature flag "sample-group" with variant "123"
