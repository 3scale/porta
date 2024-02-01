@javascript
Feature: Audience > Accounts > Listing > Account
  Background:
    Given a provider is logged in
    And a buyer "Bob"
    And a product "My API"
    And the following application plans:
      | Product | Name       | Requires approval |
      | My API  | Basic      |                   |
      | My API  | Restricted | true              |

  Scenario: No applications, no widget
    Given the buyer has no applications
    When they go to the overview page of account "Bob"
    Then they should not be able to see the application widget

  Scenario: With 1 application only, the widget is visible
    Given the following applications:
      | Buyer | Name   | Plan  |
      | Bob   | My App | Basic |
    When they go to the overview page of account "Bob"
    Then they should see the following table within the application widget:
      | Name    | My App |
      | Service | My API |
      | Plan    | Basic  |
      | State   | Live   |
    And should not see "Create new key"

  Scenario: With multiple applications, the widget is hidden
    Given the following applications:
      | Buyer | Name      | Plan  |
      | Bob   | My App    | Basic |
      | Bob   | Other App | Basic |
    When they go to the overview page of account "Bob"
    Then they should not be able to see the application widget

  Scenario: When plan requires approval, application is pending
    Given the following applications:
      | Buyer | Name      | Plan       |
      | Bob   | Super App | Restricted |
    And they go to the overview page of account "Bob"
    Then they should see the following table within the application widget:
      | Name    | Super App  |
      | Service | My API     |
      | Plan    | Restricted |
      | State   | Pending    |
