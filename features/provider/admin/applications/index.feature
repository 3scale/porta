@javascript
Feature: Audience > Applications

  As a provider, I want to see a table with all my applications and be able to sort, filter, search
  and manage them.

  Background:
    Given a provider
    And a product "My API"
    And another product "Another API"
    And the following application plans:
      | Product     | Name      | Cost per month | Setup fee |
      | My API      | Cheap     | 0              | 0         |
      | My API      | Expensive | 100            | 10        |
      | Another API | Bronze    |                | 5         |
    And a buyer "Bob"
    And a buyer "Jane"

  Rule: No apps
    Background:
      Given the provider logs in

    Scenario: Empty state
      When they go to the admin portal applications page
      Then they should see "No applications yet"
      And there should be a link to "Add an application"

  Rule: Apps
    Background:
      And the following applications:
        | Buyer | Name            | Plan      | Created at        |
        | Bob   | Another API App | Bronze    | December 10, 2023 |
        | Bob   | Bob's App       | Cheap     | December 11, 2023 |
        | Jane  | Jane's Lite App | Cheap     | December 12, 2023 |
        | Jane  | Jane's Full App | Expensive | December 13, 2023 |
      And the provider logs in

  Scenario: Multiple services providers have a column for service
    Given the provider has "multiple_services" visible
    When they go to the admin portal applications page
    Then they should see the following table:
      | Name            | State | Account | Service     | Plan      | Created on        | Traffic on |
      | Jane's Full App | live  | Jane    | My API      | Expensive | December 13, 2023 |            |
      | Jane's Lite App | live  | Jane    | My API      | Cheap     | December 12, 2023 |            |
      | Bob's App       | live  | Bob     | My API      | Cheap     | December 11, 2023 |            |
      | Another API App | live  | Bob     | Another API | Bronze    | December 10, 2023 |            |

  Scenario: Single service providers have no column for service
    Given the provider has "multiple_services" denied
    When they go to the admin portal applications page
    Then they should see the following table:
      | Name            | State | Account | Plan      | Created on        | Traffic on |
      | Jane's Full App | live  | Jane    | Expensive | December 13, 2023 |            |
      | Jane's Lite App | live  | Jane    | Cheap     | December 12, 2023 |            |
      | Bob's App       | live  | Bob     | Cheap     | December 11, 2023 |            |
      | Another API App | live  | Bob     | Bronze    | December 10, 2023 |            |

  Scenario: There is a column for the plan cost (free or paid)
    Given the provider has "finance" visible
    When they go to the admin portal applications page
    Then they should see the following table:
      | Name            | State | Account | Service     | Plan      | Created on        | Traffic on | Paid? |
      | Jane's Full App | live  | Jane    | My API      | Expensive | December 13, 2023 |            | paid  |
      | Jane's Lite App | live  | Jane    | My API      | Cheap     | December 12, 2023 |            | free  |
      | Bob's App       | live  | Bob     | My API      | Cheap     | December 11, 2023 |            | free  |
      | Another API App | live  | Bob     | Another API | Bronze    | December 10, 2023 |            | paid  |

  Scenario: Navigation via the dashboard widget
    Given they go to the provider dashboard
    When they follow "4 Applications" within the audience dashboard widget
    Then the current page is the admin portal applications page

  Scenario: Navigation via Context selector
    When they select "Audience" from the context selector
    And press "Applications" within the main menu
    And follow "Listing" within the main menu's section Applications
    Then the current page is the admin portal applications page

  Scenario: Searching by multiple criteria
    Given they go to the admin portal applications page
    When the table is filtered with:
      | filter | value |
      | Name   | Bob   |
      | Plan   | Cheap |
      | State  | Live  |
    Then the table should contain the following:
      | Name      | Account |
      | Bob's App | Bob     |

  Scenario: Searching by plan
    Given they go to the admin portal applications page with 1 record per page
    And they should see 4 pages
    When the table is filtered with:
      | filter | value |
      | Plan   | Cheap |
    And follow "Account" within the table header
    Then the table should contain the following:
      | Account |
      | Bob     |
    And they should see 2 pages

  Scenario Outline: Ordering
    Given they go to the admin portal applications page
    When they follow "<order by>" within the table header
    Then the table should be sorted by "<order by>"

    Examples:
      | order by   |
      | Name       |
      | State      |
      | Account    |
      | Created on |
      | Traffic on |
