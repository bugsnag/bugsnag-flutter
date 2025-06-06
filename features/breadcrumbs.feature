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

Scenario: Http Wrapper Breadcrumbs
    Given I run "HttpBreadcrumbScenario"
    And I wait to receive an error
    Then the error payload field "events" is an array with 1 elements
    And the error payload field "events.0.breadcrumbs" is an array with 2 elements
    And the error payload field "events.0.breadcrumbs.1.name" equals "package:http request succeeded"
    And the error payload field "events.0.breadcrumbs.1.type" equals "request"
    And the error payload field "events.0.breadcrumbs.1.metaData.status" equals 200
    And the error payload field "events.0.breadcrumbs.1.metaData.method" equals "GET"
    And the error payload field "events.0.breadcrumbs.1.metaData.duration" is greater than 1
    And the error payload field "events.0.breadcrumbs.1.metaData.url" equals "http://www.google.com"
    And the error payload field "events.0.breadcrumbs.1.metaData.responseContentLength" is greater than 1
    And the error payload field "events.0.breadcrumbs.1.metaData.urlParams" equals "test=test"

Scenario: Dart IO Wrapper Breadcrumbs
    Given I run "DartIoHttpBreadcrumbScenario"
    And I wait to receive an error
    Then the error payload field "events" is an array with 1 elements
    And the error payload field "events.0.breadcrumbs" is an array with 2 elements
    And the error payload field "events.0.breadcrumbs.1.name" equals "dart:io request succeeded"
    And the error payload field "events.0.breadcrumbs.1.type" equals "request"
    And the error payload field "events.0.breadcrumbs.1.metaData.status" equals 200
    And the error payload field "events.0.breadcrumbs.1.metaData.method" equals "GET"
    And the error payload field "events.0.breadcrumbs.1.metaData.duration" is greater than 1
    And the error payload field "events.0.breadcrumbs.1.metaData.url" equals "http://www.google.com"
    # TODO: Skipped pending PLAT-14348
    #And the error payload field "events.0.breadcrumbs.1.metaData.responseContentLength" is greater than 1
    And the error payload field "events.0.breadcrumbs.1.metaData.urlParams" equals "test=test"

