Feature: OnError callbacks

  Scenario: Filter and modify events in OnError
    Given I run "OnErrorScenario"
    And I wait to receive an error
    Then the exception "message" equals "Not ignored"
    And on iOS, the event "threads.0.stacktrace.0.symbolAddress" is not null
