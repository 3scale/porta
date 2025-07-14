@commit-transactions @javascript
Feature: Edit Invoice
  In order to make invoices work with my accounting
  As a provider
  I Want to edit invoice

  Background:
    Given a provider is logged in on 1st January 2011
    And the provider is charging its buyers
    And a buyer "bob" signed up to provider "foo.3scale.localhost"
    And an invoice of buyer "bob" for January, 2011
    And an invoice of buyer "bob" for February, 2011
    And they go to invoice "2011-01-00000001" admin portal page

  Scenario: Edit of invoice billing period fails
    And I follow "Edit"
    And I fill in "Billing Period" with "2011"
    And I press "Update Invoice"
    Then I should see "Billing period format should be YYYY-MM"

  Scenario: Edit of invoice id succeeds but id is not unique
    And I follow "Edit"
    And I fill in "ID" with "2011-02-00000001"
    And I press "Update Invoice"
    Then I should see "This invoice id is already in use"

  Scenario: Eedit of billing period should succeed
    And I follow "Edit"
    And I fill in "Billing Period" with "2011-02"
    And I press "Update Invoice"
    Then I should see "Invoice for February 2011"

  Scenario: Edit of billing period should not raise exception
    And I follow "Edit"
    And I fill in "Billing Period" with "some-invalid-text"
    And I press "Update Invoice"
    Then I should see "Billing period format should be YYYY-MM"
