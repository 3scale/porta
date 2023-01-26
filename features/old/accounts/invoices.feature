@ignore-backend
Feature: Show invoices from account's page (#16015909)
  In order to check and edit buyer's invoices quickly
  As a provider
  I want to be able to list buyer's invoices from his account page if I've billing enabled

  Scenario: List the invoices
    Given a provider "xyz.3scale.localhost"
      And provider "xyz.3scale.localhost" is charging its buyers in prepaid mode
      And an application plan "Fixed" of provider "xyz.3scale.localhost" for 0 monthly
      And a buyer "zoidberg" signed up to application plan "Fixed"
      And an invoice of buyer "zoidberg" for January, 2011
      And current domain is the admin domain of provider "xyz.3scale.localhost"
      And I log in as provider "xyz.3scale.localhost"
     When I go to the buyer account page for "zoidberg"
      And I follow "1 Invoice"
     Then I should see 1 invoice
     When I follow "2011-01-00000001"
     Then I should see "Invoice for January 2011"
      And I should still be in the "Accounts" in the main menu

  Scenario: Don't show invoices when billing is not enabled
    Given a provider "xyz.3scale.localhost"
      And provider "xyz.3scale.localhost" has "finance" denied
      And an application plan "Fixed" of provider "xyz.3scale.localhost" for 0 monthly
      And a buyer "zoidberg" signed up to application plan "Fixed"

    And current domain is the admin domain of provider "xyz.3scale.localhost"
    When I log in as provider "xyz.3scale.localhost"
      And I go to the buyer account page for "zoidberg"

    Then I should not see "Invoices"

  Scenario: Ability to add line items to opened invoice
     Given a provider "xyz.3scale.localhost"
        And provider "xyz.3scale.localhost" is charging its buyers in prepaid mode
        And an application plan "Fixed" of provider "xyz.3scale.localhost" for 0 monthly
        And a buyer "zoidberg" signed up to application plan "Fixed"
        And an invoice of buyer "zoidberg" for January, 2011

        And current domain is the admin domain of provider "xyz.3scale.localhost"
        And I log in as provider "xyz.3scale.localhost"
        And I go to the buyer account page for "zoidberg"
        And I follow "1 Invoice"
        And I follow "2011-01-00000001"

      # TODO: Properly check if order is opened

      Then I should see "Add"
