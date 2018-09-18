Feature: Buyer's payment details
  In order to pay for the service
  As a buyer
  I want to enter my credit card details

  Background:
    Given the time is 1st June 2009
    And a provider "foo.example.com"
    And provider "foo.example.com" is charging
    Given provider "foo.example.com" has "finance" switch visible

  Scenario: Informational billing, credit card details provided.
    Given a published plan "Basic" of provider "foo.example.com"
      And provider "foo.example.com" manages payments with "braintree_blue"
      And a buyer "eric" signed up to application plan "Basic"
      And buyer "eric" has last digits of credit card number "1234" and expiration date March, 2018
    When I log in as "eric" on foo.example.com
     When I follow "Settings"
     When I follow "Credit Card Details"
    Then I should see "Credit card number"
      And I should see "XXXX-XXXX-XXXX-1234"
      And I should see "Expiration date"
      And I should see "March, 2018"
