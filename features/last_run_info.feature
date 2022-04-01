Feature: LastRunInfo

  Scenario: Native crash during launch
    Given I run "NativeCrashScenario" and relaunch the crashed app
    * I run "LastRunInfoScenario"
    * I wait to receive 2 errors
    Then the event "app.isLaunching" is true
    * the event "unhandled" is true
    When I discard the oldest error
    Then the event "app.isLaunching" is false
    * the event "metaData.lastRunInfo.consecutiveLaunchCrashes" equals 1
    * the event "metaData.lastRunInfo.crashed" is true
    * the event "metaData.lastRunInfo.crashedDuringLaunch" is true
