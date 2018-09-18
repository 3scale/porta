@ignore-backend
Feature: Show invoices from account's page (#16015909)
  In order to check and edit buyer's invoices quickly
  As a provider
  I want to be able to list buyer's invoices from his account page if I've billing enabled

  Scenario: List the invoices
    Given a provider "xyz.example.com" with prepaid billing enabled
      And an application plan "Fixed" of provider "xyz.example.com" for 0 monthly
      And a buyer "zoidberg" signed up to application plan "Fixed"
      And an invoice of buyer "zoidberg" for January, 2011

      And current domain is the admin domain of provider "xyz.example.com"
      And I log in as provider "xyz.example.com"
      And I go to the buyer account page for "zoidberg"

    Then I should see "1 Invoice"

    When I follow "1 Invoice"
    Then I should see 1 invoice

    When I follow "Show"
    Then I should see "Invoice for January 2011"
      And I should still be in the "Developers" in the main menu

  Scenario: Don't show invoices when billing is not enabled
    Given a provider "xyz.example.com" with billing disabled
      And an application plan "Fixed" of provider "xyz.example.com" for 0 monthly
      And a buyer "zoidberg" signed up to application plan "Fixed"

    And current domain is the admin domain of provider "xyz.example.com"
    When I log in as provider "xyz.example.com"
      And I go to the buyer account page for "zoidberg"

    Then I should not see "Invoices"

  Scenario: Ability to add line items to opened invoice
     Given a provider "xyz.example.com" with prepaid billing enabled
        And an application plan "Fixed" of provider "xyz.example.com" for 0 monthly
        And a buyer "zoidberg" signed up to application plan "Fixed"
        And an invoice of buyer "zoidberg" for January, 2011

        And current domain is the admin domain of provider "xyz.example.com"
        And I log in as provider "xyz.example.com"
        And I go to the buyer account page for "zoidberg"
        And I follow "1 Invoice"
        And I follow "Show" within opened order

      # TODO: Properly check if order is opened

      Then I should see "Add"



