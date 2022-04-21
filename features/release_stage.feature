Feature: enabledReleaseStages

  @slow
  Scenario: Event discarded if releaseStage not in enabledReleaseStages
    When I run "ReleaseStageScenario"
    Then I should receive no errors
