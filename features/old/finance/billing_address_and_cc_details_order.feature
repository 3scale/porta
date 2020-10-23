@stripe
Feature: Credit card details
  In order to pay for the service
  As a buyer
  I want to enter my credit card details and keep them up to date

  Background:
    Given the time is 1st June 2009
    Given a provider "foo.3scale.localhost"
      And provider "foo.3scale.localhost" is charging
      And provider "foo.3scale.localhost" has "finance" switch visible
    Given the current domain is "foo.3scale.localhost"

    And an application plan "Pro" of provider "foo.3scale.localhost"
    And a buyer without billing address "kenny" signed up to application plan "Pro"
    And a buyer "stan" signed up to application plan "Pro"

  Scenario: Entering cc details disabled if billing address not provided
    Given the current domain is "foo.3scale.localhost"
      And provider "foo.3scale.localhost" manages payments with "stripe"
    When I log in as "kenny" on "foo.3scale.localhost"
     And I go to the stripe credit card details page
    Then I should not see button "Edit Credit Card Details"

  Scenario: Billing Address fields are shown if they exist
    Given the current domain is "foo.3scale.localhost"
      And provider "foo.3scale.localhost" manages payments with "stripe"
    When I log in as "stan" on "foo.3scale.localhost"
     And I go to the stripe credit card details page

    Then I should see "Timbuktu"
      And I should see "Mali"
      And I should see "10100"
      And I should see "+123 456 789"

  Scenario: Credit card fields are shown if they exist
    Given the current domain is "foo.3scale.localhost"
      And buyer "stan" has last digits of credit card number "1234" and expiration date March, 2018
      And provider "foo.3scale.localhost" manages payments with "stripe"
    When I log in as "stan" on foo.3scale.localhost
    And I go to the stripe credit card details page

    Then I should see "Expiration date"
      And I should see "March, 2018"
      And I should see "Credit card number"
      And I should see "XXXX-XXXX-XXXX-1234"

  Scenario: Billing address errors (for all pg)
    Given the current domain is "foo.3scale.localhost"
      And provider "foo.3scale.localhost" manages payments with "stripe"
     When I log in as "kenny" on "foo.3scale.localhost"
      And I go to the stripe credit card details page
      And I follow "First add a billing address"

      And I fill in "Phone" with "+34123123212"
      And I press "Save"
    Then I should see "Failed to update your billing address data."
