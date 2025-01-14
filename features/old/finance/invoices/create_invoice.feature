Feature: Create invoice
  In order to add custom charges even thought there is none from the system
  As a provider
  I want to be able to create an invoice on demand

  Background:
    Given a provider is logged in on 1st Jan 2009
    And the provider is charging its buyers in prepaid mode
    And the default product of the provider has name "My API"
    And the following application plan:
      | Product | Name  |
      | My API  | Fixed |
    And a buyer "zoidberg" signed up to application plan "Fixed"

  @javascript
  Scenario: Create and view the invoice
    And go to the invoices page of account "zoidberg"
    Then I should not see "open"
    When the date is 1st January 2009
    And I follow "Create invoice"
    Then I should see "Invoice successfully created"
    And I should see "open"
    Then I follow "Create invoice"
    And confirm the dialog
    When I follow "2009-01-00000001"
    Then I should see "Invoice for January 2009"
