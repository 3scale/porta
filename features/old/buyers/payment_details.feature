Feature: Payment Details
  In order to manage my credit card details
  As a buyer
  I want to be able to enter data in remote forms

  Background:
    Given a provider "foo.3scale.localhost"
      And provider "foo.3scale.localhost" has multiple applications enabled
      And provider "foo.3scale.localhost" is charging
      And provider "foo.3scale.localhost" has "finance" switch visible
      And provider "foo.3scale.localhost" has "useraccountarea" enabled
      And a buyer "randomdude" signed up to provider "foo.3scale.localhost"

  @stripe
  Scenario: Navigate to payment details page
    Given provider "foo.3scale.localhost" manages payments with "stripe"
    When I log in as "randomdude" on "foo.3scale.localhost"
     And I go to the stripe credit card details page
    Then I should be on the stripe credit card details page

  @stripe
  Scenario: Redirect to correct payment_gateway url
    Given provider "foo.3scale.localhost" manages payments with "stripe"
    When I log in as "randomdude" on "foo.3scale.localhost"
     And I go to the credit card details page
    Then I should be on the stripe credit card details page

  Scenario: Can't enter cc details if no billing address
    Given provider "foo.3scale.localhost" manages payments with "braintree_blue"
    When I log in as "randomdude" on "foo.3scale.localhost"
     And I go to the braintree credit card details page
    Then I should not see "Edit Credit Card Details"
