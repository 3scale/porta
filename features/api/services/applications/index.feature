@javascript
Feature: Product > Applications

  As a provider, I want to see a table with all the applications of a product and be able to sort,
  filter, search and manage them.

  Background:
    Given a provider
    And a product "My API" with no plans
    And another product "Another API" with no plans
    And the following application plans:
      | Product     | Name      | Cost per month | Setup fee |
      | My API      | Cheap     | 0              | 0         |
      | My API      | Expensive | 100            | 10        |
      | Another API | Bronze    |                | 5         |
    And a buyer "Bob"
    And a buyer "Jane"
    And the following applications:
      | Buyer | Name            | Plan      | Created at        |
      | Bob   | Another API App | Bronze    | December 10, 2023 |
      | Bob   | Bob's App       | Cheap     | December 11, 2023 |
      | Jane  | Jane's Lite App | Cheap     | December 12, 2023 |
      | Jane  | Jane's Full App | Expensive | December 13, 2023 |
    And the provider logs in

  Scenario: Navigation via the products widget
    Given they go to the provider dashboard
    When they select action "Applications" of "My API" within the products widget
    Then the current page is product "My API" applications page

  Scenario: Navigation via Context selector
    When they select "Products" from the context selector
    And follow "My API"
    And press "Applications" within the main menu
    And follow "Listing" within the main menu's section Applications
    Then the current page is product "My API" applications page

  Scenario: Empty state
    Given a product "No Apps API"
    When they go to product "No Apps API" applications page
    Then they should see "No applications yet"
    And there should be a link to "Add an application"

  Scenario: Only the current service applications are listed
    When they go to product "My API" applications page
    Then they should see the following table with exact columns:
      | Name            | State | Account | Plan      | Created on        | Traffic on |
      | Jane's Full App | live  | Jane    | Expensive | December 13, 2023 |            |
      | Jane's Lite App | live  | Jane    | Cheap     | December 12, 2023 |            |
      | Bob's App       | live  | Bob     | Cheap     | December 11, 2023 |            |
    When they go to product "Another API" applications page
    Then they should see the following table with exact columns:
      | Name            | State | Account | Created on        | Traffic on |
      | Another API App | live  | Bob     | December 10, 2023 |            |

  Scenario: Plan column is hidden when the API has a single plan
    When they go to product "My API" applications page
    Then the table has a column "Plan"
    When they go to product "Another API" applications page
    Then the table does not have a column "Plan"

  Scenario: Paid? column is shown when finance is enabled
    When the provider has "finance" denied
    And they go to product "My API" applications page
    Then the table does not have a column "Paid?"
    When the provider has "finance" allowed
    And they go to product "My API" applications page
    Then the table has a column "Paid?"
