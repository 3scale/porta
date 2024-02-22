@javascript
Feature: Audience > Accounts > Listing > Account > Applications

  Background:
    Given a provider
    And a product "My API"
    And the following application plan:
      | Product | Name |
      | My API  | Free |
    And a buyer "Bob"
    And the following application:
      | Buyer | Name   | Product |
      | Bob   | My App | My API  |
    And the provider logs in

  Scenario: Navigation
    Given they go to buyer "Bob" overview page
    When follow "1 Application" within the secondary nav
    Then the current page is buyer "Bob" applications page

  Scenario: Application details
    When they go to buyer "Bob" applications page
    Then they should see "Applications for Bob"
    And they should see the following table:
      | Name   | State | Service | Plan |
      | My App | live  | My API  | Free |
