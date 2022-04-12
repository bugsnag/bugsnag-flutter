@skip_android
Feature: App Hangs (iOS only)

  @slow
  Scenario: App hangs are not reported by default
    Given I run "AppHangScenario"
    Then I should receive no errors

  Scenario: App hangs are reported when enabled
    Given I configure the app to run in the "enabled" state
    * I run "AppHangScenario"
    * I wait to receive an error
    Then the exception "errorClass" equals "App Hang"
    * the event "unhandled" is false
