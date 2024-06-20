@javascript
Feature: Audience > Accounts > Applications

  As a provider, I want to see a table with all the applications of a buyer and be able to sort,
  filter, search and manage them.

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
    And the following applications:
      | Buyer | Name            | Plan      | Created at        |
      | Bob   | Another API App | Bronze    | December 10, 2023 |
      | Bob   | Bob's App       | Cheap     | December 11, 2023 |
      | Jane  | Jane's Lite App | Cheap     | December 12, 2023 |
      | Jane  | Jane's Full App | Expensive | December 13, 2023 |
    And the provider logs in

  Scenario: Navigation from accounts listing
    Given the provider has "multiple_applications" visible
    When they go to the buyer accounts page
    And they follow "2" in the 1st row
    Then the current page is buyer "Jane" applications page

  Scenario: Navigation from account overview
    Given they go to buyer "Bob" overview page
    When follow "2 Applications" within the secondary nav
    Then the current page is buyer "Bob" applications page

  Scenario: Empty state
    Given a buyer "Appsless"
    When they go to buyer "Appsless" applications page
    Then they should see "No applications yet"
    And there should be a link to "Add an application"

  Scenario: Application details
    When they go to buyer "Bob" applications page
    Then they should see "Applications for Bob"
    And they should see the following table:
      | Name            | State | Service     | Plan   | Created on        | Traffic on |
      | Bob's App       | live  | My API      | Cheap  | December 11, 2023 |            |
      | Another API App | live  | Another API | Bronze | December 10, 2023 |            |
