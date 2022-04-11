Feature: Feature flags

  Scenario: Mutating feature flags after startup
    When I run "FeatureFlagsScenario"
    Then I wait to receive an error
    And the error is valid for the error reporting API version "4.0" for the "Flutter Bugsnag Notifier" notifier
    And the event contains the following feature flags:
      | featureFlag | variant |
      | two         | bar     |
      | three       |         |
      | four        |         |
      | five        | six     |
      | callback    | yes     |
