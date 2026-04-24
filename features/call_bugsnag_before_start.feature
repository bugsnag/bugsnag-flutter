Feature: Developers can verify Bugsnag initialization using isStarted

  Scenario: Methods work correctly after initialization with isStarted verification
    Given I run "CallBugsnagBeforeStartScenario"
    Then I should receive no error

