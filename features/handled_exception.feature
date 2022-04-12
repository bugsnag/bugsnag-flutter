Feature: bugsnag.notify

  Scenario: Notify with an Exception
    Given I run "HandledExceptionScenario"
    * I wait to receive an error
    Then the error is valid for the error reporting API version "4.0" for the "Flutter Bugsnag Notifier" notifier
    * the exception "errorClass" equals "_Exception"
    * the exception "message" equals "test error message"
    * the event "unhandled" is false
    * the error payload field "events.0.threads" is a non-empty array
    * the "file" of stack frame 5 equals "package:MazeRunner/scenarios/handled_exception_scenario.dart"
    * the "method" of stack frame 5 equals "HandledExceptionScenario.run"
    * the "lineNumber" of stack frame 5 equals 25
    * on iOS, the "codeIdentifier" of stack frame 5 is not null
    * on iOS, the "type" of stack frame 5 equals "dart"
    * the event "metaData.flutter.defaultRouteName" equals "/"
    * the event "metaData.flutter.initialLifecycleState" is not null
    * the event "metaData.flutter.lifecycleState" is not null

  Scenario: Notify with a callback
    Given I configure the app to run in the "callback" state
    * I run "HandledExceptionScenario"
    * I wait to receive an error
    Then the error is valid for the error reporting API version "4.0" for the "Flutter Bugsnag Notifier" notifier
    * the exception "errorClass" equals "_Exception"
    * the exception "message" equals "test error message"
    * the event "unhandled" is true
    * the error payload field "events.0.metaData.callback.message" equals "Hello, World!"
    * the error payload field "events.0.breadcrumbs.0.name" equals "Crumbs!"
    * the error payload field "events.0.threads" is a non-empty array
    * the "file" of stack frame 5 equals "package:MazeRunner/scenarios/handled_exception_scenario.dart"
    * the "method" of stack frame 5 equals "HandledExceptionScenario.run"
    * the "lineNumber" of stack frame 5 equals 13
    * on iOS, the "codeIdentifier" of stack frame 5 is not null
    * on iOS, the "type" of stack frame 5 equals "dart"
    * on iOS, the event "app.dsymUUIDs.0" is not null
    * the event "metaData.flutter.defaultRouteName" equals "/"
    * the event "metaData.flutter.initialLifecycleState" is not null
    * the event "metaData.flutter.lifecycleState" is not null
    * the event "user.id" equals "3"
    * the event "user.email" equals "bugs.nag@bugsnag.com"
    * the event "user.name" equals "Bugs Nag"
