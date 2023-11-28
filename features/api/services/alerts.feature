@javascript
Feature: Product > Analytics > Alerts

  Background:
    Given a provider
    And the default product of the provider has name "My Product"
    And the provider has a free application plan "Default"
    And a buyer "Jane" of the provider
    And a buyer "Bob" of the provider
    And the the provider has the following applications:
      | Buyer | Name     | Plan    |
      | Jane  | Jane App | Default |
      | Bob   | Bob App  | Default |
    And the following alerts:
      | Application | Timestamp               | Utilization | Level | Message        | Alert id |
      | Bob App     | 2010-10-15 14:14:00 UTC | 1.5         | 150   | foos: 30 of 20 | 7        |
      | Bob App     | 2010-10-14 11:11:00 UTC | 0.9         | 90    | foos: 18 of 20 | 6        |
      | Jane App    | 2010-09-13 15:04:00 UTC | 2           | 200   | bars: 20 of 10 | 5        |
      | Jane App    | 2010-09-13 12:20:00 UTC | 0.5         | 50    | foos: 2 of 4   | 1        |
    And the provider logs in

  Scenario: Navigation via vertical menu
    Given the current page is the provider dashboard
    When follow "My Product" within the apis dashboard widget
    And press "Analytics" within the main menu
    And follow "Alerts" within the main menu
    Then the current page is the alerts of "My Product"

  Scenario: Navigation via product overview
    Given the current page is the provider dashboard
    When follow "My Product" within the apis dashboard widget
    And follow "Show all limit alerts for this service"
    Then the current page is the alerts of "My Product"

  Scenario: Listing alerts
    Given they go to the alerts of "My Product"
    Then they should see the following table:
      | Account | Application | Message        | Level   | Time (UTC)               |              |
      | Bob     | Bob App     | foos: 30 of 20 | ≥ 150 % | 15 Oct 2010 14:14:00 UTC | Delete\nRead |
      | Bob     | Bob App     | foos: 18 of 20 | ≥ 90 %  | 14 Oct 2010 11:11:00 UTC | Delete\nRead |
      | Jane    | Jane App    | bars: 20 of 10 | ≥ 200 % | 13 Sep 2010 15:04:00 UTC | Delete\nRead |
      | Jane    | Jane App    | foos: 2 of 4   | ≥ 50 %  | 13 Sep 2010 12:20:00 UTC | Delete\nRead |

  Scenario: Reading alerts
    Given they go to the alerts of "My Product"
    When they follow "Read" in the 1st row
    And follow "Read" in the 3rd row
    Then they should see the following table:
      | Account | Application | Message        | Level   | Time (UTC)               |              |
      | Bob     | Bob App     | foos: 30 of 20 | ≥ 150 % | 15 Oct 2010 14:14:00 UTC | Delete       |
      | Bob     | Bob App     | foos: 18 of 20 | ≥ 90 %  | 14 Oct 2010 11:11:00 UTC | Delete\nRead |
      | Jane    | Jane App    | bars: 20 of 10 | ≥ 200 % | 13 Sep 2010 15:04:00 UTC | Delete       |
      | Jane    | Jane App    | foos: 2 of 4   | ≥ 50 %  | 13 Sep 2010 12:20:00 UTC | Delete\nRead |

  Scenario: Deleting alerts
    Given they go to the alerts of "My Product"
    When they press "Delete" in the 1st row and confirm dialog box
    Then they should see the following table:
      | Account | Application | Message        | Level   | Time (UTC)               |              |
      | Bob     | Bob App     | foos: 18 of 20 | ≥ 90 %  | 14 Oct 2010 11:11:00 UTC | Delete\nRead |
      | Jane    | Jane App    | bars: 20 of 10 | ≥ 200 % | 13 Sep 2010 15:04:00 UTC | Delete\nRead |
      | Jane    | Jane App    | foos: 2 of 4   | ≥ 50 %  | 13 Sep 2010 12:20:00 UTC | Delete\nRead |

  Scenario: Marking all alerts as read
    Given they go to the alerts of "My Product"
    When they select toolbar action "Mark all as read" and confirm dialog box
    Then they should see the following table:
      | Account | Application | Message        | Level   | Time (UTC)               |        |
      | Bob     | Bob App     | foos: 30 of 20 | ≥ 150 % | 15 Oct 2010 14:14:00 UTC | Delete |
      | Bob     | Bob App     | foos: 18 of 20 | ≥ 90 %  | 14 Oct 2010 11:11:00 UTC | Delete |
      | Jane    | Jane App    | bars: 20 of 10 | ≥ 200 % | 13 Sep 2010 15:04:00 UTC | Delete |
      | Jane    | Jane App    | foos: 2 of 4   | ≥ 50 %  | 13 Sep 2010 12:20:00 UTC | Delete |

  Scenario: Deleting all alerts
    Given they go to the alerts of "My Product"
    When they select toolbar action "Delete all" and confirm dialog box
    Then they should see "All clear"
