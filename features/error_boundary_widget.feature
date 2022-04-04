Feature: ErrorBoundary Widget

  Scenario: Errors are reported by ErrorBoundary widgets
    Given I run "ErrorBoundaryWidgetScenario"

    # TODO: PLAT-8234
    And on Android, I relaunch the app
    And on Android, I configure Bugsnag for "UnhandledExceptionScenario"

    And I wait to receive an error
    Then the error payload field "events" is an array with 1 elements
    And the exception "errorClass" equals "_Exception"
    # TODO: Disabled until we find another way
    # And the event "context" equals "ErrorBoundary 1"
    And the error payload field "events.0.breadcrumbs" is an array with 1 elements
    And the error payload field "events.0.exceptions.0.message" equals "I am a very bad widget."
    And the error payload field "events.0.threads" is a non-empty array
