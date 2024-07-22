Feature: Dev Portal > Invoices > Download PDF

  As a buyer, I want to have the PDF versions of my invoices

  Background:
    Given a provider on 1st January 2011
    And the provider is charging its buyers in prepaid mode
    And the provider has "finance" switch visible
    And a buyer "Jane"
    And the following invoices:
      | Buyer | Month         | Friendly ID      | State |
      | Jane  | January, 2011 | 2011-01-00000001 | Paid  |
    And the buyer logs in

  Scenario: Download PDF from the invoices table
    When they go to the dev portal invoices page
    Then there should be a secure link to download the PDF of invoice "2011-01-00000001"

  Scenario: Download PDF from the invoice detail
    When they go to the invoice "2011-01-00000001" dev portal page
    Then there should be a secure link to download the PDF
