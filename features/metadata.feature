Feature: Metadata

  Scenario: Includes global metadata in events
    When I run "MetadataScenario"
    Then I wait to receive an error
    And the error is valid for the error reporting API version "4.0" for the "Flutter Bugsnag Notifier" notifier
    And the event "metaData.custom.key" equals "value"
    And the event "metaData.custom.numbers" equals 123
    And the event "metaData.custom.bool" is true
    And the event "metaData.custom.string" equals "message"
    And the event "metaData.custom.password" equals "[REDACTED]"
    And the event "metaData.custom.to-be-removed" is null
    And the event "metaData.old-section" is null

  Scenario: Allows editing of metadata in callbacks
    When I configure the app to run in the "callback" state
    And I run "MetadataScenario"
    Then I wait to receive an error
    And the error is valid for the error reporting API version "4.0" for the "Flutter Bugsnag Notifier" notifier
    And the event "metaData.custom.key" equals "value"
    And the event "metaData.custom.numbers" equals 123
    And the event "metaData.custom.bool" is true
    And the event "metaData.custom.string" equals "message"
    And the event "metaData.callback.callbackRun" is true
    And the event "metaData.custom.password" is null
    And the event "metaData.custom.to-be-removed" is null
    And the event "metaData.old-section" is null
