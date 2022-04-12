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

  Scenario: Mutating feature flags in a callback
    When I configure the app to run in the "callback" state
    And I run "FeatureFlagsScenario"
    Then I wait to receive an error
    And the error is valid for the error reporting API version "4.0" for the "Flutter Bugsnag Notifier" notifier
    And the event contains the following feature flags:
      | featureFlag | variant |
      | two         | bar     |
      | four        |         |
      | five        | six     |
      | callback    | yes     |
