Feature: Reporting crash events

  Scenario: A basic native crash
    When I run "NativeCrashScenario" and relaunch the crashed app
    And I configure Bugsnag for "NativeCrashScenario"
    And I wait to receive an error
