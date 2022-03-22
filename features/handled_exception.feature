Feature: bugsnag.notify

  Scenario: Notify with an Exception
    When I run "HandledExceptionScenario"
    Then I wait to receive an error
    And the error payload field "events" is an array with 1 elements
    And the exception "errorClass" equals "_Exception"
    And the event 0 is handled
    And the error payload field "events.0.exceptions.0.message" equals "test error message"
    And the error payload field "events.0.threads.0.name" equals "main"

  Scenario: Notify with a callback
    When I configure the app to run in the "callback" state
    And I run "HandledExceptionScenario"
    Then I wait to receive an error
    And the error payload field "events" is an array with 1 elements
    And the exception "errorClass" equals "_Exception"
    And the event 0 is unhandled
    And the error payload field "events.0.exceptions.0.message" equals "test error message"
    And the error payload field "events.0.threads.0.name" equals "main"