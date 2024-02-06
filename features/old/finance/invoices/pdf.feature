@ignore-backend
Feature: Invoice PDFs
  In order to print my invoices and satisfy the beaurocratic beast
  As a provider or buyer
  I want to have the PDF versions of the invoices

  Background:
    Given a provider exists on 1st August 2011
    And the provider is charging its buyers
    And the default product of the provider has name "My API"
    And the following application plan:
      | Product | Name  | State     | Cost per month |
      | My API  | Fixed | Published | 200            |
    And a buyer "bob" signed up to application plan "Fixed"
    And an issued invoice of buyer "bob" for August, 2011
    And current domain is the admin domain of provider "foo.3scale.localhost"

  @commit-transactions @javascript
  Scenario: Provider side links on the invoice index and details
    Given current domain is the admin domain of provider "foo.3scale.localhost"
    And I log in as provider "foo.3scale.localhost"
    When I go to invoices issued by me for "bob"
    Then I should see secure PDF link for invoice 2011-08-00000001
    When I navigate to invoice 2011-08 issued by me for "bob"
    Then I should see secure PDF link for the shown invoice

  @commit-transactions
  Scenario: Buyer side links on the invoice index and details
    Given the current domain is "foo.3scale.localhost"
    And I log in as "bob"
    And provider "foo.3scale.localhost" has "finance" switch visible
    When I go to my invoices
    Then I should see secure PDF link for invoice 2011-08-00000001
    When I follow "Show 2011-08-00000001"
    Then I should see secure PDF link for the shown buyer invoice
