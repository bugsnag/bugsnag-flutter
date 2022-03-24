Feature: Attach to running native Bugsnag instance

  Scenario: attach with a handled exception
    When I configure the app to run in the "handled" state
    And I run "AttachBugsnagScenario"
    Then I wait to receive an error
    And the error payload field "events" is an array with 1 elements
    And the exception "errorClass" equals "_Exception"
    And the error payload field "events.0.unhandled" is false
    And the error payload field "events.0.exceptions.0.message" equals "Exception with attached info"
    And the error payload field "events.0.threads.0.name" equals "main"
    And the event "severity" equals "warning"

    And the event "user.id" equals "test-user-id"
    And the event "user.email" is null
    And the event "user.name" equals "Old Man Tables"

    And the event "context" equals "flutter-test-context"
    And event 0 contains the feature flag "demo-mode" with no variant
    And event 0 contains the feature flag "sample-group" with variant "123"
