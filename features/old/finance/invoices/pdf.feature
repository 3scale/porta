@ignore-backend
Feature: Invoice PDFs
  In order to print my invoices and satisfy the beaurocratic beast
  As a provider or buyer
  I want to have the PDF versions of the invoices

  Background:
    And a provider "foo.example.com" with billing enabled
    And a published plan "Fixed" of provider "foo.example.com"
    And plan "Fixed" has monthly fee of 200
    And a buyer "bob" signed up to application plan "Fixed"
    And an issued invoice of buyer "bob" for August, 2011
    And current domain is the admin domain of provider "foo.example.com"

  @commit-transactions
  Scenario: Provider side links on the invoice index and details
  Given current domain is the admin domain of provider "foo.example.com"
    And I log in as provider "foo.example.com"

    When I navigate to invoices issued by me for "bob"
    Then I should see secure PDF link for invoice 2011-08-00000001

    When I navigate to invoice 2011-08 issued by me for "bob"
    Then I should see secure PDF link for the shown invoice

  @commit-transactions
  Scenario: Buyer side links on the invoice index and details
  Given the current domain is "foo.example.com"
    And I log in as "bob"
    And provider "foo.example.com" has "finance" switch visible

   When I go to my invoices
   Then I should see secure PDF link for invoice 2011-08-00000001
   When I follow "Show 2011-08-00000001"
   Then I should see secure PDF link for the shown buyer invoice
