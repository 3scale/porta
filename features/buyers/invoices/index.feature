@javascript
Feature: Audience > Accounts > Buyer > Invoices

  Background:
    Given a provider is logged in on 1st Jan 2009
    And the provider is charging its buyers in prepaid mode
    And the default product of the provider has name "My API"
    And the following application plan:
      | Product | Name  |
      | My API  | Fixed |
    And a buyer "Bob" signed up to application plan "Fixed"

  Scenario: Navigation
    Given they go to the buyer accounts page
    When they follow "Bob"
    And they follow "0 Invoices"
    Then the current page is the invoices page of account "Bob"

  Scenario: Create an invoice
    Given the date is 1st January 2009
    When they go to the invoices page of account "Bob"
    And they follow "Create an invoice"
    Then they should see "Invoice successfully created"
    And should see "January, 2009"
    And they should see "1 Invoice"

  Scenario: Can't create invoice when buyer already has an open invoice
    Given the following invoice:
      | Buyer | Month         | Friendly ID      | State |
      | Bob   | January, 2009 | 2011-02-00000002 | Open  |
    And they go to the invoices page of account "Bob"
    And the table should have 1 row
    Then there should not be a link to "Create invoice"

  Scenario: Can't create invoice when buyer already has a pending invoice
    Given the following invoice:
      | Buyer | Month         | Friendly ID      | State   |
      | Bob   | January, 2009 | 2011-02-00000002 | Pending |
    And they go to the invoices page of account "Bob"
    And the table should have 1 row
    Then there should be a link to "Create invoice"

  Scenario: Create invoice when buyer only have closed invoices
    Given the following invoice:
      | Buyer | Month         | Friendly ID      | State |
      | Bob   | January, 2009 | 2009-01-00000001 | Paid  |
      | Bob   | January, 2009 | 2009-01-00000002 | Paid  |
    And they go to the invoices page of account "Bob"
    And the table should have 2 row
    Then there should be a link to "Create invoice"
