Feature: Buyer's payment details
  In order to pay for the service
  As a buyer
  I want to enter my credit card details

  Background:
    Given the time is 1st June 2009
    And a provider "foo.3scale.localhost"
    And provider "foo.3scale.localhost" is charging
    Given provider "foo.3scale.localhost" has "finance" switch visible

  @javascript @chrome
  Scenario: Informational billing, credit card details provided.
    Given a published plan "Basic" of provider "foo.3scale.localhost"
      And provider "foo.3scale.localhost" manages payments with "braintree_blue"
      And a buyer "eric" signed up to application plan "Basic"
      And buyer "eric" has last digits of credit card number "1234" and expiration date March, 2018
    When I log in as "eric" on foo.3scale.localhost
     When I follow "Settings"
     When I follow "Credit Card Details"
    Then I should see "Credit card number"
      And I should see "XXXX-XXXX-XXXX-1234"
      And I should see "Expiration date"
      And I should see "March, 2018"
