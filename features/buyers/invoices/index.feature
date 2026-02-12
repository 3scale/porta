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

  Scenario: Create an invoice from an empty view
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
    When they click on "Create invoice"
    And confirm the dialog
    Then the table should have 1 row
    And they should see "1 Invoice"

  Scenario Outline: Can create invoice when buyer has a <state> invoice
    Given the following invoice:
      | Buyer | Month         | Friendly ID      | State   |
      | Bob   | January, 2009 | 2009-01-00000001 | <state> |
    And they go to the invoices page of account "Bob"
    And the table should have 1 row
    When they follow "Create invoice"
    Then the table should contain the following:
      | Month         | State         |
      | January, 2009 | open          |
      | January, 2009 | <state_lower> |
    And they should see "2 Invoices"

    Examples:
      | state     | state_lower |
      | Pending   | pending     |
      | Cancelled | cancelled   |
      | Paid      | paid        |
