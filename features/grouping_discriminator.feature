Feature: Grouping Discriminator

  Scenario: Grouping Discriminator
    When I run "GroupingDiscriminatorScenario"
    And I wait to receive 3 errors
    And the error is valid for the error reporting API version "4.0" for the "Flutter Bugsnag Notifier" notifier
    And I sort the errors by the payload field "events.0.exceptions.0.message"

    And the exception "message" equals "GroupingDiscriminator-1"
    And the event "groupingDiscriminator" is null
    And I discard the oldest error
    And the exception "message" equals "GroupingDiscriminator-2"
    And the event "groupingDiscriminator" equals "Global GroupingDiscriminator"
    And I discard the oldest error
    And the exception "message" equals "GroupingDiscriminator-3"
    And the event "groupingDiscriminator" equals "Callback GroupingDiscriminator"
