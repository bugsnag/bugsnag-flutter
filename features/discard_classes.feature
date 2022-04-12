Feature: discardClasses

  Scenario: Discard a handled exception
    When I run "DiscardClassesScenario"
    And I wait to receive an error
    Then the error is valid for the error reporting API version "4.0" for the "Flutter Bugsnag Notifier" notifier with the apiKey "abc12312312312312312312312312312"
    And the error payload field "events.0.breadcrumbs" is an array with 1 elements
    And the exception "errorClass" equals "FormatException"

  Scenario: Discard a handled exception with callback
    Given I configure the app to run in the "callback" state
    When I run "DiscardClassesScenario"
    And I wait to receive an error
    Then the error is valid for the error reporting API version "4.0" for the "Flutter Bugsnag Notifier" notifier with the apiKey "abc12312312312312312312312312312"
    And the error payload field "events.0.breadcrumbs" is an array with 1 elements
    And the event "metaData.origin.callback" is true
    And the exception "errorClass" equals "FormatException"

  Scenario: Discard an unhandled exception
    Given I configure the app to run in the "unhandled" state
    When I run "DiscardClassesScenario"
    And I wait to receive an error
    Then the error is valid for the error reporting API version "4.0" for the "Flutter Bugsnag Notifier" notifier with the apiKey "abc12312312312312312312312312312"
    And the error payload field "events.0.breadcrumbs" is an array with 1 elements
    And the exception "errorClass" equals "FormatException"