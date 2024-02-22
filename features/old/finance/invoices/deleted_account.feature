@javascript
Feature: Invoices of deleted account
  In order to check old invoices
  As a provider
  I want to be able to see invoices of deleted accounts

  Background:
    Given the date is 25th January 2012
    Given a provider is logged in on 1st January 2011
    Given the provider is charging its buyers in prepaid mode
    And the default product of the provider has name "My API"
    And the following application plan:
      | Product | Name | State     |
      | My API  | Plan | Published |
    And a buyer "bob" signed up to application plan "Plan"

  @commit-transactions
  Scenario: I cannot but view the invoices of a deleted buyer
    Given an invoice of buyer "bob" for January, 2011 with items:
      | name   | cost |
      | Custom | 42   |
    And I issue the invoice number "2011-01-00000001"
    And account "bob" is deleted
    And I go to all provider's invoices page
    Then I should see 1 invoice
    When I follow "2011-01-00000001"
    Then I should see "2011-01-00000001"
    But I should not see "Cancel invoice"
    And I should not see "Mark as paid"
    And I should not see /Charge$/
