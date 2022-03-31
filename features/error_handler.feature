Feature: bugsnag.errorHandler

  Scenario: Reports unhandled errors from guarded zones
    When I configure the app to run in the "zone" state
    And I run "ErrorHandlerScenario"
    # TODO: PLAT-8234
    And on Android, I relaunch the app
    And on Android, I configure Bugsnag for "ErrorHandlerScenario"
    Then I wait to receive an error
    And the error is valid for the error reporting API version "4.0" for the "Flutter Bugsnag Notifier" notifier
    And the exception "errorClass" equals "_CastError"
    And the error payload field "events.0.unhandled" is true
    And the error payload field "events.0.exceptions.0.message" equals "Null check operator used on a null value"
    And the error payload field "events.0.threads" is a non-empty array

  Scenario: Reports unhandled errors from Future.onError
    When I configure the app to run in the "future" state
    And I run "ErrorHandlerScenario"
    # TODO: PLAT-8234
    And on Android, I relaunch the app
    And on Android, I configure Bugsnag for "ErrorHandlerScenario"
    Then I wait to receive an error
    And the error is valid for the error reporting API version "4.0" for the "Flutter Bugsnag Notifier" notifier
    And the exception "errorClass" equals "String"
    And the error payload field "events.0.unhandled" is true
    And the error payload field "events.0.exceptions.0.message" equals "exception from the future"
    And the error payload field "events.0.threads" is a non-empty array
