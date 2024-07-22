@javascript
Feature: Audience > Finance > Invoices PDF

  As a provider or buyer, I want to have the PDF version of the invoices

  Background:
    Given a provider is logged in on 1st January 2011
    And the provider is charging its buyers in prepaid mode
    And a buyer "Jane"
    And the following invoices:
      | Buyer | Month         | Friendly ID      | State |
      | Jane  | January, 2011 | 2011-01-00000002 | Paid  |

  Scenario: Download PDF from the index table
    When they go to the admin portal invoices page
    And the table is filtered with:
      | filter | value            |
      | Number | 2011-01-00000002 |
    Then there should be a link to "Download PDF"

  Scenario: Download PDF from the invoice detail
    When they go to the invoice "2011-01-00000002" admin portal page
    Then there should be a link to "Download PDF"
