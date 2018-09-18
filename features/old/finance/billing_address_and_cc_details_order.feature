Feature: Credit card details
  In order to pay for the service
  As a buyer
  I want to enter my credit card details and keep them up to date

  Background:
    Given the time is 1st June 2009
    Given a provider "foo.example.com"
      And provider "foo.example.com" is charging
      And provider "foo.example.com" has "finance" switch visible
    Given the current domain is "foo.example.com"

    And an application plan "Pro" of provider "foo.example.com"
    And a buyer without billing address "kenny" signed up to application plan "Pro"
    And a buyer "stan" signed up to application plan "Pro"

  Scenario: Entering cc details disabled if billing address not provided
    Given the current domain is foo.example.com
      And provider "foo.example.com" manages payments with "stripe"
    When I log in as "kenny" on foo.example.com
     And I go to the stripe credit card details page
    Then I should not see button "Edit Credit Card Details"

  Scenario: Entering cc details allowed after billing address provided
    Given the current domain is foo.example.com
      And provider "foo.example.com" manages payments with "stripe"
    When I log in as "kenny" on foo.example.com
     And I go to the stripe credit card details page
    Then I should not see button "Edit Credit Card Details"

    When I follow "First add a billing address"

    Then I should see "Billing Address"

    When I fill in "Contact / Company Name" with "comp"
      And I fill in "Address" with "C/LLacuna 162"
      And I fill in "City" with "Barcelona"
      And I select "Spain" from "Country"
      And I fill in "ZIP / Postal Code" with "08080"
      And I fill in "Phone" with "+34123123212"
      And I press "Save"

    Then I should see the fields:
      | Card number          |
      | CVC                  |
    And I should see button "Save details"

  Scenario: Billing Address fields are shown if they exist
    Given the current domain is foo.example.com
      And provider "foo.example.com" manages payments with "stripe"
    When I log in as "stan" on foo.example.com
     And I go to the stripe credit card details page

    Then I should see "Timbuktu"
      And I should see "Mali"
      And I should see "10100"
      And I should see "+123 456 789"

  Scenario: Credit card fields are shown if they exist
    Given the current domain is foo.example.com
      And buyer "stan" has last digits of credit card number "1234" and expiration date March, 2018
      And provider "foo.example.com" manages payments with "stripe"
    When I log in as "stan" on foo.example.com
    And I go to the stripe credit card details page

    Then I should see "Expiration date"
      And I should see "March, 2018"
      And I should see "Credit card number"
      And I should see "XXXX-XXXX-XXXX-1234"

  Scenario: Billing address errors (for all pg)
    Given the current domain is foo.example.com
      And provider "foo.example.com" manages payments with "stripe"
     When I log in as "kenny" on foo.example.com
      And I go to the stripe credit card details page
      And I follow "First add a billing address"

      And I fill in "Phone" with "+34123123212"
      And I press "Save"
    Then I should see "Failed to update your billing address data."
