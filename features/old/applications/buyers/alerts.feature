Feature: API Usage alerts
  In order to contact my users if they violated usage limits
  As a provider
  I want to see usage alerts and violations

  Background:
    Given a provider "foo.3scale.localhost"
      And a application plan "Default" of provider "foo.3scale.localhost"
    Given a buyer "alice" signed up to provider "foo.3scale.localhost"
      And buyer "alice" has application "Aliget"
      And a metric "foos" with friendly name "Number of Foos" of provider "foo.3scale.localhost"
      And a metric "bars" with friendly name "Number of Bars" of provider "foo.3scale.localhost"
      And I have following API alerts:
      | Application | Timestamp               | Utilization | Level | Message         | Alert id |
      | Aliget      | 2010-10-14 11:11:00 UTC | 0.9         | 90    | foos: 18 of 20  | 6        |
      | Aliget      | 2010-10-15 14:14:00 UTC | 1.5         | 150   | foos: 30 of 20  | 7        |
    Given the current domain is "foo.3scale.localhost"

  @ignore-backend @ignore-backend-alerts
  Scenario: Navigation
    Given I am logged in as "alice"
    When I am on the "Aliget" application page
    Then I should not see "API Alerts"

    When default service of provider "foo.3scale.localhost" has allowed following alerts:
      | Who   | How | Levels |
      | buyer | web | 50, 90 |
    And I am on the "Aliget" application page
    Then I should see "usage alert(s)"


  Scenario: Listing alerts and violations
    Given I log in as "alice"
      And default service of provider "foo.3scale.localhost" has allowed following alerts:
        | Who   | How | Levels |
        | buyer | web | 50, 90 |
    When I go to the alerts page of application "Aliget"

    Then I should see the following API alerts:
      | Message         | Level   | Time                     |
      | foos: 30 of 20  | ≥ 150 % | 15 Oct 2010 14:14:00 UTC |
      | foos: 18 of 20  | ≥ 90 %  | 14 Oct 2010 11:11:00 UTC |

  Scenario: Deleting alerts
    Given I log in as "alice"
      And default service of provider "foo.3scale.localhost" has allowed following alerts:
        | Who   | How | Levels |
        | buyer | web | 50, 90 |
     When I go to the alerts page of application "Aliget"
      And I follow "Delete alert" for the 2nd API alert

    Then I should see 1 API alert
    Then I should see only the following API alert:
      | Message         | Level   | Time                     |
      | foos: 30 of 20  | ≥ 150 % | 15 Oct 2010 14:14:00 UTC |

  Scenario: Deleting all alerts
    Given I log in as "alice"
      And default service of provider "foo.3scale.localhost" has allowed following alerts:
        | Who   | How | Levels |
        | buyer | web | 50, 90 |
     When I go to the alerts page of application "Aliget"
      And I press "Delete all"

    Then I should be on the alerts page of application "Aliget"
     And I should not see any API alerts

