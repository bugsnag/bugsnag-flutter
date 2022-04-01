Feature: Session Tracking

  Scenario: Manual session tracking
    Given I run "ManualSessionsScenario"
    * I wait to receive a session
    * I wait to receive 4 errors
    Then the received errors match:
      | exceptions.0.message | session   |
      | No session           | null      |
      | Session started      | @not_null |
      | Session paused       | null      |
      | Session resumed      | @not_null |
