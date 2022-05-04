Feature: navigation breadcrumbs

  Scenario: Leaves navigation breadcrumbs and context
    When I run "NavigatorBreadcrumbScenario"
    Then I wait to receive an error
    And the error is valid for the error reporting API version "4.0" for the "Flutter Bugsnag Notifier" notifier
    And the exception "errorClass" equals "_Exception"
    And the event "severity" equals "warning"
    And the error payload field "events" is an array with 1 elements
    And the error payload field "events.0.breadcrumbs" is an array with 3 elements
    And the error payload field "events.0.breadcrumbs.1.name" equals "Navigator.didPush()"
    And the error payload field "events.0.breadcrumbs.1.type" equals "navigation"
    And the error payload field "events.0.breadcrumbs.1.metaData.route" equals "/test-route"
    And the error payload field "events.0.breadcrumbs.2.name" equals "Navigator.didReplace()"
    And the error payload field "events.0.breadcrumbs.2.type" equals "navigation"
    And the error payload field "events.0.breadcrumbs.2.metaData.oldRoute" equals "/test-route"
    And the error payload field "events.0.breadcrumbs.2.metaData.newRoute" equals "Cupertino Route"
