Feature: API Usage alerts
  In order to contact my users if they violated usage limits
  As a provider
  I want to see usage alerts and violations

  Background:
    Given a provider "foo.example.com"
      And provider "foo.example.com" has multiple applications enabled
      And a application plan "Default" of provider "foo.example.com"

    Given a buyer "bob" signed up to provider "foo.example.com"
      And a buyer "alice" signed up to provider "foo.example.com"
      And buyer "bob" has application "Bobget"
      And buyer "alice" has application "Aliget"
      And a metric "foos" with friendly name "Number of Foos" of provider "foo.example.com"
      And a metric "bars" with friendly name "Number of Bars" of provider "foo.example.com"
      And I have following API alerts:
      | Application | Timestamp           | Utilization | Level | Message         | Alert id |
      | Bobget      | 2010-09-13 12:20:00 | 0.5         | 50    | foos: 2 of 4    | 1        |
      | Bobget      | 2010-09-13 15:04:00 | 2           | 200   | bars: 20 of 10  | 5        |
      | Aliget      | 2010-10-14 11:11:00 | 0.9         | 90    | foos: 18 of 20  | 6        |
      | Aliget      | 2010-10-15 14:14:00 | 1.5         | 150   | foos: 30 of 20  | 7        |

    Given current domain is the admin domain of provider "foo.example.com"
    Given I am logged in as provider "foo.example.com"

  Scenario: Navigation
    When I go to the provider dashboard
     And I follow "API" within the main menu
     And I follow "Show all limit alerts for this service"
    Then I should be on the API alerts page of service "API" of provider "foo.example.com"

  Scenario: Listing alerts and violations
    When I go to the API alerts page
    Then I should see the following unread API alerts:
      | Account | Application | Message        | Level   | Time (UTC)               | State  |
      | alice   | Aliget      | foos: 30 of 20 | ≥ 150 % | 15 Oct 2010 14:14:00 UTC | unread |
      | alice   | Aliget      | foos: 18 of 20 | ≥ 90 %  | 14 Oct 2010 11:11:00 UTC | unread |
      | bob     | Bobget      | bars: 20 of 10 | ≥ 200 % | 13 Sep 2010 15:04:00 UTC | unread |
      | bob     | Bobget      | foos: 2 of 4   | ≥ 50 %  | 13 Sep 2010 12:20:00 UTC | unread |

  @javascript
  Scenario: Reading alerts
    When I go to the API alerts page of service "API" of provider "foo.example.com"
     And I follow "Read" for the 1st API alert

    Then I should be on the API alerts page of service "API" of provider "foo.example.com"
    Then I should see the following API alerts:
      | Account | Application | Message        | Level   | Time (UTC)               | State  |
      | alice   | Aliget      | foos: 30 of 20 | ≥ 150 % | 15 Oct 2010 14:14:00 UTC | read   |
      | alice   | Aliget      | foos: 18 of 20 | ≥ 90 %  | 14 Oct 2010 11:11:00 UTC | unread |
      | bob     | Bobget      | bars: 20 of 10 | ≥ 200 % | 13 Sep 2010 15:04:00 UTC | unread |
      | bob     | Bobget      | foos: 2 of 4   | ≥ 50 %  | 13 Sep 2010 12:20:00 UTC | unread |

    When I follow "Read" for the 3rd API alert

    Then I should see the following API alerts:
      | Account | Application | Message        | Level   | Time (UTC)               | State  |
      | alice   | Aliget      | foos: 30 of 20 | ≥ 150 % | 15 Oct 2010 14:14:00 UTC | read   |
      | alice   | Aliget      | foos: 18 of 20 | ≥ 90 %  | 14 Oct 2010 11:11:00 UTC | unread |
      | bob     | Bobget      | bars: 20 of 10 | ≥ 200 % | 13 Sep 2010 15:04:00 UTC | read   |
      | bob     | Bobget      | foos: 2 of 4   | ≥ 50 %  | 13 Sep 2010 12:20:00 UTC | unread |

  @javascript
  Scenario: Deleting alerts
    When I go to the API alerts page
     And I press "Delete" for the 1st API alert

    Then I should see 3 API alerts

    When I press "Delete" for the 2nd API alert

    Then I should see only the following API alert:
      | Account | Application | Message        | Level  | Time (UTC)               | State  |
      | alice   | Aliget      | foos: 18 of 20 | ≥ 90 % | 14 Oct 2010 11:11:00 UTC | unread |
      | bob     | Bobget      | foos: 2 of 4   | ≥ 50 % | 13 Sep 2010 12:20:00 UTC | unread |

  @javascript
  Scenario: Marking all alerts as read
    When I go to the API alerts page of service "API" of provider "foo.example.com"
      And I follow "Mark All As Read"

    Then I should be on the API alerts page of service "API" of provider "foo.example.com"
    Then I should not see any unread API alerts

  @javascript
  Scenario: Deleting all alerts
    When I go to the API alerts page
      And I follow "Delete All" and I confirm dialog box

    Then I should be on the API alerts page
      And I should not see any API alerts

    #When I reload the page
    #Then I still should not see any API violations
