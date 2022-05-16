Feature: Auto Detect Enabled Errors

  @skip_ios
  Scenario: Native errors can be disabled separately to Dart errors
    Given I configure the app to run in the "detectDartExceptions" state
    When I run "DetectEnabledErrorsScenario" and relaunch the crashed app
    And I configure Bugsnag for "DetectEnabledErrorsScenario"
    * I wait to receive an error
    Then the error payload field "events" is an array with 1 elements
    * the event "unhandled" is true
    * the exception "errorClass" equals "_Exception"
    * the exception "message" equals "Exception from Dart"

  @skip_ios
  Scenario: Dart errors can be disabled separately to JVM errors
    Given I configure the app to run in the "detectJvmExceptions" state
    When I run "DetectEnabledErrorsScenario" and relaunch the crashed app
    And I configure Bugsnag for "DetectEnabledErrorsScenario"
    * I wait to receive an error
    Then the error payload field "events" is an array with 1 elements
    * the event "unhandled" is true
    * the exception "errorClass" equals "java.lang.RuntimeException"
    * the exception "message" equals "crash from Java"