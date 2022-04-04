Feature: Unhandled Flutter Exceptions

  Scenario: Unhandled Flutter Exception
    When I run "UnhandledExceptionScenario"

    # TODO: PLAT-8234
    And on Android, I relaunch the app
    And on Android, I configure Bugsnag for "UnhandledExceptionScenario"

    Then I wait to receive an error
    And the error payload field "events" is an array with 1 elements
    And the exception "errorClass" equals "_Exception"
    And the error payload field "events.0.unhandled" is true
    And the error payload field "events.0.exceptions.0.message" equals "test error message"
    And the error payload field "events.0.threads" is a non-empty array
