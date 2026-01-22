@commit-transactions @javascript
Feature: Show Invoice

  Background:
    Given a provider is logged in on 1st January 2011
    And the provider is charging its buyers
    And a buyer "Bob" signed up to the provider
    And the following invoice:
      | Buyer | Month         | Friendly ID      | State | Total cost |
      | Bob   | January, 2011 | 2011-01-00000001 | Paid  | 20.00      |
    And they go to invoice "2011-01-00000001" admin portal page

  Scenario: Navigation
    Given they go to the provider dashboard
    And they follow "Billing"
    And they follow "Invoices" within the main menu
    When they follow "2011-01-00000001"
    Then they should be on invoice "2011-01-00000001" admin portal page

  Scenario: Invoice has no transactions
    Given invoice "2011-01-00000001" has no payment transactions
    And they go to invoice "2011-01-00000001" admin portal page
    Then they should see "No transactions registered for this invoice." within the transactions card

  Scenario: Invoice has some transactions
    Given invoice "2011-01-00000001" has some payment transactions
    And they go to invoice "2011-01-00000001" admin portal page
    And table "Transactions table" should have 1 row

  Scenario: Open invoice actions
    Given the following invoice:
      | Buyer | Month          | Friendly ID      | State |
      | Bob   | February, 2011 | 2011-02-00000002 | Open  |
    And they go to invoice "2011-02-00000002" admin portal page
    Then there should be a button to "Generate PDF"
    And there should be a button to "Issue invoice"
    And there should be a button to "Cancel invoice"
    But there should not be a button to "Charge"
    And there should not be a button to "Mark as paid"

  Scenario: Pending invoice actions
    Given the following invoice:
      | Buyer | Month          | Friendly ID      | State   |
      | Bob   | February, 2011 | 2011-02-00000002 | Pending |
    And they go to invoice "2011-02-00000002" admin portal page
    Then there should be a button to "Generate PDF"
    And there should be a button to "Charge"
    And there should be a button to "Mark as paid"
    And there should be a button to "Cancel invoice"
    But there should not be a button to "Issue invoice"

  Scenario: Paid invoice actions
    Given the following invoice:
      | Buyer | Month          | Friendly ID      | State |
      | Bob   | February, 2011 | 2011-02-00000002 | Paid  |
    And they go to invoice "2011-02-00000002" admin portal page
    Then there should be a button to "Regenerate PDF"
    But there should not be a button to "Issue invoice"
    And there should not be a button to "Charge"
    And there should not be a button to "Mark as paid"
    And there should not be a button to "Cancel invoice"

  Scenario: Cancelled invoice actions
    Given the following invoice:
      | Buyer | Month          | Friendly ID      | State     |
      | Bob   | February, 2011 | 2011-02-00000002 | Cancelled |
    And they go to invoice "2011-02-00000002" admin portal page
    Then there should be a button to "Generate PDF"
    But there should not be a button to "Charge"
    But there should not be a button to "Issue"
    And there should not be a button to "Mark as paid"
    And there should not be a button to "Cancel invoice"
