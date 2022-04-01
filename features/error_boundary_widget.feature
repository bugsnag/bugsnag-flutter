Feature: ErrorBoundary Widget

  Scenario: Errors are reported by ErrorBoundary widgets
    Given I run "ErrorBoundaryWidgetScenario"
    And I wait to receive an error
    Then the error payload field "events" is an array with 1 elements
    And the exception "errorClass" equals "_Exception"
    And the event "context" equals "ErrorBoundary 1"
    And the error payload field "events.0.breadcrumbs" is an array with 1 elements
    And the error payload field "events.0.exceptions.0.message" equals "I am a very bad widget."
    And the error payload field "events.0.threads" is a non-empty array
