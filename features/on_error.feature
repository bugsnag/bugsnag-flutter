Feature: OnError callbacks

  Scenario: Filter and modify events in OnError
    Given I run "OnErrorScenario"
    And I wait to receive an error
    Then the exception "message" equals "Not ignored"
    And the event "app.id" equals "app_id"
    And the event "device.id" equals "device_id"
    And the event "severity" equals "info"
    And on iOS, the event "threads.0.stacktrace.0.symbolAddress" is not null
