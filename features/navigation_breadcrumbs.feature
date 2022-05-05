Feature: navigation breadcrumbs

  Scenario: Leaves navigation breadcrumbs and context
    When I run "NavigatorBreadcrumbScenario"
    Then I wait to receive an error
    And the error is valid for the error reporting API version "4.0" for the "Flutter Bugsnag Notifier" notifier
    And the exception "errorClass" equals "_Exception"
    And the event "severity" equals "warning"
    And the error payload field "events" is an array with 1 elements
    And the error payload field "events.0.context" equals "/"
    And the error payload field "events.0.breadcrumbs" is an array with 5 elements

    And the error payload field "events.0.breadcrumbs.1.name" equals "Route pushed on navigator"
    And the error payload field "events.0.breadcrumbs.1.type" equals "navigation"
    And the error payload field "events.0.breadcrumbs.1.metaData.route.name" equals "/test-route"
    And the error payload field "events.0.breadcrumbs.1.metaData.route.arguments.search" equals "bugsnag"

    And the error payload field "events.0.breadcrumbs.2.name" equals "Route replaced on navigator"
    And the error payload field "events.0.breadcrumbs.2.type" equals "navigation"
    And the error payload field "events.0.breadcrumbs.2.metaData.oldRoute.name" equals "/test-route"
    And the error payload field "events.0.breadcrumbs.2.metaData.newRoute.name" equals "Cupertino Route"

    And the error payload field "events.0.breadcrumbs.3.name" equals "Route removed from navigator"
    And the error payload field "events.0.breadcrumbs.3.type" equals "navigation"
    And the error payload field "events.0.breadcrumbs.3.metaData.route.name" equals "/removed-route"
    And the error payload field "events.0.breadcrumbs.3.metaData.previousRoute.name" equals "/previous-route"

    And the error payload field "events.0.breadcrumbs.4.name" equals "Route popped off navigator"
    And the error payload field "events.0.breadcrumbs.4.type" equals "navigation"
    And the error payload field "events.0.breadcrumbs.4.metaData.route.name" equals "/popped-route"
    And the error payload field "events.0.breadcrumbs.4.metaData.previousRoute.name" equals "/"
