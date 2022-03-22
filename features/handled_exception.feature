Feature: bugsnag.notify

  Scenario: Notify with an Exception
    When I run "HandledExceptionScenario"
    Then I wait to receive an error
    And the error payload field "events" is an array with 1 elements
    And the exception "errorClass" equals "Exception"
    And the event "exceptions.0.message" is "test error message"
    And the error payload field "events.0.threads.0.name" is "main"