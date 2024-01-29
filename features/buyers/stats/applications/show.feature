@javascript
Feature: Product > Applications Listing > Application > Analytics

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

  Scenario: Navigation from dashboard
    Given the current page is the provider dashboard
    When they follow "1 Application" within the audience dashboard widget
    And follow "My App" within the table body
    And follow "Analytics" within the secondary nav
    Then the current page is application "My App" traffic stats page

  Scenario: Navigation from product
    Given the current page is the provider dashboard
    When they follow "My API" within the products widget
    And follow "My App" within the latest apps
    And follow "Analytics" within the secondary nav
    Then the current page is application "My App" traffic stats page
