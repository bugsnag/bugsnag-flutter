Feature: Unhandled Flutter Exceptions

  Scenario: Unhandled Flutter Exception
    When I run "UnhandledExceptionScenario"
    Then I wait to receive an error
    And the error payload field "events" is an array with 1 elements
    And the exception "errorClass" equals "_Exception"
    And the error payload field "events.0.unhandled" is true
    And the error payload field "events.0.exceptions.0.message" equals "test error message"
    And the error payload field "events.0.threads" is a non-empty array
    And the event "metaData.flutter.defaultRouteName" equals "/"
    And the event "metaData.flutter.errorContext" equals "during a task callback"
    And the event "metaData.flutter.errorLibrary" equals "scheduler library"
    And the event "metaData.flutter.initialLifecycleState" is not null
    And the event "metaData.flutter.lifecycleState" is not null

  Scenario: Unhandled Flutter Exception with autoDetectErrors=false
    Given I configure the app to run in the "noDetectErrors" state
    When I run "UnhandledExceptionScenario"
    Then I should receive no error

  Scenario: Unhandled Native Exception with autoDetectErrors=false
    Given I configure the app to run in the "noDetectErrors" state
    When I run "NativeCrashScenario"
    Then I should receive no error
