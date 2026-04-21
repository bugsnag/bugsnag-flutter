Feature: Calling Bugsnag methods before start() fails without isStarted

  Scenario: Methods throw exception when called before start()
    Given I run "CallBugsnagBeforeStartScenario"
    Then I should not receive an error

