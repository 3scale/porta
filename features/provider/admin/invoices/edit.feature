@commit-transactions @javascript
Feature: Edit Invoice

  Background:
    Given a provider is logged in on 1st January 2011
    And the provider is charging its buyers
    And a buyer "bob" signed up to the provider
    And an invoice of buyer "bob" for January, 2011
    And an invoice of buyer "bob" for February, 2011
    And they go to invoice "2011-01-00000001" admin portal edit page

  Scenario: Navigation
    When they go to invoice "2011-01-00000001" admin portal page
    And they follow "Edit"
    Then they should be on invoice "2011-01-00000001" admin portal edit page

  Scenario: Update billing period
    When the form is submitted with:
      | Billing Period | 2011-02 |
    Then they should see "Invoice for February 2011"
    And a toast alert is displayed with text "Invoice was successfully updated"

  Scenario: Wrong billing period
    When the form is submitted with:
      | Billing Period | 2011 |
    Then field "Billing Period" has inline error "Billing period format should be YYYY-MM"
    When the form is submitted with:
      | Billing Period | 2005-12 |
    Then field "Billing Period" has inline error "must be between the provider account creation date and 12 months from now"

  Scenario: Use a duplicated id
    Given they go to invoice "2011-01-00000001" admin portal page
    And they should not see "This invoice id is already in use"
    When they follow "Edit"
    And the form is submitted with:
      | ID | 2011-02-00000001 |
    Then a toast alert is displayed with text "Invoice was successfully updated"
    And they should see "This invoice id is already in use"
