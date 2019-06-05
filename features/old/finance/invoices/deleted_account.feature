@javascript
Feature: Invoices of deleted account
  In order to check old invoices
  As a provider
  I want to be able to see invoices of deleted accounts

 Background:
  Given the date is 25th January 2012
  Given a provider "xyz.example.com" with prepaid billing enabled
  Given provider "xyz.example.com" has "finance" switch allowed
    And an application plan "Plan" of provider "xyz.example.com"
    And a buyer "bob" signed up to application plan "Plan"
  Given current domain is the admin domain of provider "xyz.example.com"

 @commit-transactions
 Scenario: I cannot but view the invoices of a deleted buyer
    Given an invoice of buyer "bob" for January, 2011 with items:
      | name   | cost |
      | Custom |   42 |
     And I issue the invoice number "2011-01-00000001"
     And account "bob" is deleted

    When I log in as provider "xyz.example.com"
     And I go to the invoices issued by me
    Then I should see 1 invoice

    When I follow "2011-01-00000001"
    Then I should see "2011-01-00000001"
     But I should not see "Cancel invoice"
     And I should not see "Mark as paid"
     And I should not see /Charge$/
