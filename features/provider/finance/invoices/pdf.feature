@javascript
Feature: Audience > Billing > Invoices > Generate PDF

  As a provider or buyer, I want to have the PDF version of the invoices

  Background:
    Given a provider is logged in on 1st January 2011
    And the provider is charging its buyers in prepaid mode
    And a buyer "Jane"

  Scenario: Open invoices don't have generated a PDF
    Given the following invoices:
      | Buyer | Month         | Friendly ID      | State     |
      | Jane  | January, 2011 | 2011-01-00000001 | Open      |
    When they go to the admin portal invoices page
    And there should not be a link to "Download PDF"
    When they follow "2011-01-00000001"
    Then there should not be a link to "Download PDF"
    But there should be a button to "Generate PDF"

  Scenario: Paid invoices do have generated a PDF
    Given the following invoices:
      | Buyer | Month         | Friendly ID      | State     |
      | Jane  | January, 2011 | 2011-01-00000001 | Paid      |
    When they go to the admin portal invoices page
    And there should be a link to "Download PDF"
    When they follow "2011-01-00000001"
    Then there should be a link to "Download PDF"
    And there should be a button to "Regenerate PDF"
    But there should not be a button to "Generate PDF"
