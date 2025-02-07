@javascript
Feature: Audience > Accounts > Invoices

  Buyer accounts have its own tab for invoices. It should have the same functionality as
  Audience > Billing > Invoices.

  Background:
    Given a provider is logged in on 1st January 2011
    And a buyer "Bob"
    And the provider is charging its buyers

  Scenario: Navigation
    Given they go to the the buyer accounts page
    And they follow "Bob"
    And they follow "0 Invoices"
    Then the current page is buyer "Bob" invoices page

  Scenario: List buyer account's invoices
    Given the following invoices:
      | Buyer | Month          | Friendly ID      |
      | Bob   | January, 2011  | 2011-01-00000001 |
      | Bob   | February, 2011 | 2011-02-00000001 |
    When they go to buyer "Bob" overview page
    And follow "2 Invoices"
    Then the table should contain the following:
      | ID               | Month          | State | Amount   | Download          |
      | 2011-01-00000001 | January, 2011  | open  | EUR 0.00 | not yet generated |
      | 2011-02-00000001 | February, 2011 | open  | EUR 0.00 | not yet generated |
    And the table does not have a column "Account"

  Scenario: Invoices tab not visible when billling disabled
    Given the provider has "finance" denied
    When they go to buyer "Bob" overview page
    Then they should not see "Invoices"

