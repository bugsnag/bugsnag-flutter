Feature: nullParameters

  Scenario: Context is set to null
    When I run "NullContextScenario"
    Then I wait to receive an error
    And the error is valid for the error reporting API version "4.0" for the "Flutter Bugsnag Notifier" notifier
    And the exception "errorClass" equals "_Exception"
    And the event "severity" equals "warning"

  Scenario: User is set to null
    When I run "NullUserScenario"
    Then I wait to receive an error
    And the error is valid for the error reporting API version "4.0" for the "Flutter Bugsnag Notifier" notifier
    And the exception "errorClass" equals "_Exception"
    And the event "severity" equals "warning"