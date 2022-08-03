Feature: Start Bugsnag from Flutter

  Scenario: Breadcrumbs
    Given I run "BreadcrumbsScenario"
    And I wait to receive an error
    Then the error payload field "events" is an array with 1 elements
    And the error payload field "events.0.breadcrumbs" is an array with 2 elements
    And the error payload field "events.0.breadcrumbs.0.name" equals "Bugsnag loaded"
    And the error payload field "events.0.breadcrumbs.0.type" equals "state"
    And the error payload field "events.0.breadcrumbs.1.metaData.foo" equals "bar"
    And the error payload field "events.0.breadcrumbs.1.metaData.object.test" equals "hello"
    And the error payload field "events.0.breadcrumbs.1.metaData.object.bool" is true
    And the error payload field "events.0.breadcrumbs.1.metaData.object.number" equals 1234
    And the error payload field "events.0.breadcrumbs.1.metaData.object.list.0" equals 'abc'
    And the error payload field "events.0.breadcrumbs.1.metaData.object.list.1" equals 4321
    And the error payload field "events.0.breadcrumbs.1.metaData.object.list.2" is true
    And the error payload field "events.0.breadcrumbs.1.name" equals "Manual breadcrumb"
    And the error payload field "events.0.breadcrumbs.1.type" equals "manual"
