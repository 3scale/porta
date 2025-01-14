@javascript
Feature: Audience > Applications > Alerts

  Background:
    Given a provider
    And a product "API 1"
    And a product "API 2"
    And the following application plans:
      | Product | Name   |
      | API 1   | Plan 1 |
      | API 2   | Plan 2 |
    And a buyer "Jane" of the provider
    And the following applications:
      | Buyer | Name          | Plan   |
      | Jane  | Application 1 | Plan 1 |
      | Jane  | Application 2 | Plan 2 |
    And the following alerts:
      | Application   | Timestamp               | Utilization | Level | Message        | Alert id |
      | Application 1 | 2010-10-15 14:14:00 UTC | 1.5         | 150   | foos: 30 of 20 | 7        |
      | Application 1 | 2010-10-14 11:11:00 UTC | 0.9         | 90    | foos: 18 of 20 | 6        |
      | Application 2 | 2010-09-13 15:04:00 UTC | 2           | 200   | bars: 20 of 10 | 5        |
      | Application 2 | 2010-09-13 12:20:00 UTC | 0.5         | 50    | foos: 2 of 4   | 1        |
    And the provider logs in

  Scenario: Navigation
    Given the current page is the provider dashboard
    When they select "Audience" from the context selector
    And press "Applications" within the main menu
    And follow "Alerts" within the main menu
    Then the current page is the alerts page

  Scenario: Listing alerts
    Given they go to the alerts page
    Then they should see the following table:
      | Account | Application   | Message        | Level   | Time (UTC)               |              |
      | Jane    | Application 1 | foos: 30 of 20 | ≥ 150 % | 15 Oct 2010 14:14:00 UTC | Delete\nRead |
      | Jane    | Application 1 | foos: 18 of 20 | ≥ 90 %  | 14 Oct 2010 11:11:00 UTC | Delete\nRead |
      | Jane    | Application 2 | bars: 20 of 10 | ≥ 200 % | 13 Sep 2010 15:04:00 UTC | Delete\nRead |
      | Jane    | Application 2 | foos: 2 of 4   | ≥ 50 %  | 13 Sep 2010 12:20:00 UTC | Delete\nRead |

  Scenario: Reading alerts
    Given they go to the alerts page
    When they follow "Read" in the 1st row
    And follow "Read" in the 3rd row
    Then they should see the following table:
      | Account | Application   | Message        | Level   | Time (UTC)               |              |
      | Jane    | Application 1 | foos: 30 of 20 | ≥ 150 % | 15 Oct 2010 14:14:00 UTC | Delete       |
      | Jane    | Application 1 | foos: 18 of 20 | ≥ 90 %  | 14 Oct 2010 11:11:00 UTC | Delete\nRead |
      | Jane    | Application 2 | bars: 20 of 10 | ≥ 200 % | 13 Sep 2010 15:04:00 UTC | Delete       |
      | Jane    | Application 2 | foos: 2 of 4   | ≥ 50 %  | 13 Sep 2010 12:20:00 UTC | Delete\nRead |

  Scenario: Deleting alerts
    Given they go to the alerts page
    When they press "Delete" in the 1st row
    And confirm the dialog
    Then they should see the following table:
      | Account | Application   | Message        | Level   | Time (UTC)               |              |
      | Jane    | Application 1 | foos: 18 of 20 | ≥ 90 %  | 14 Oct 2010 11:11:00 UTC | Delete\nRead |
      | Jane    | Application 2 | bars: 20 of 10 | ≥ 200 % | 13 Sep 2010 15:04:00 UTC | Delete\nRead |
      | Jane    | Application 2 | foos: 2 of 4   | ≥ 50 %  | 13 Sep 2010 12:20:00 UTC | Delete\nRead |

  Scenario: Marking all alerts as read
    Given they go to the alerts page
    When they select toolbar action "Mark all as read"
    And confirm the dialog
    Then they should see the following table:
      | Account | Application   | Message        | Level   | Time (UTC)               |        |
      | Jane    | Application 1 | foos: 30 of 20 | ≥ 150 % | 15 Oct 2010 14:14:00 UTC | Delete |
      | Jane    | Application 1 | foos: 18 of 20 | ≥ 90 %  | 14 Oct 2010 11:11:00 UTC | Delete |
      | Jane    | Application 2 | bars: 20 of 10 | ≥ 200 % | 13 Sep 2010 15:04:00 UTC | Delete |
      | Jane    | Application 2 | foos: 2 of 4   | ≥ 50 %  | 13 Sep 2010 12:20:00 UTC | Delete |

  Scenario: Deleting all alerts
    Given they go to the alerts page
    When they select toolbar action "Delete all"
    And confirm the dialog
    Then they should see "All clear"
