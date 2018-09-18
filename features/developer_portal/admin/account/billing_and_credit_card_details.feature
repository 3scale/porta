Feature: Billing and Credit card details
  In order to pay for the service
  As a buyer
  I want to enter my billing and credit card details and keep them up to date

  Background:
    Given a provider exists
    And the provider has a default paid application plan
    And the provider is charging
    # TODO: Test other payment gateways (adyen, authorize.net, etc)
    And the provider has testing credentials for braintree
    And the provider has "finance" switch visible
    And Braintree is stubbed to accept credit card for buyer
    And a buyer signed up to the provider

  @javascript @selenium
  Scenario: Update credit card details
    Given the buyer has valid credit card with lots of money

    When the buyer logs in to the provider
    And go to the braintree edit credit card details page
    Then I should be at url for the braintree edit credit card details page

    When I fill in the braintree credit card form
    And I press "Save details"
    Then I should see "Credit card details were successfully stored."

  @javascript @selenium
  Scenario: Update credit card details with CVV equals to "000"
    # TODO: DRY
    Given the buyer has valid credit card with lots of money

    When the buyer logs in to the provider
    And go to the braintree edit credit card details page
    Then I should be at url for the braintree edit credit card details page

    When I fill in the braintree credit card form
    And I fill in "CVV" with "000"
    And I press "Save details"
    Then I should see "Credit card details were successfully stored."

  @javascript @selenium
  Scenario: Update billing address with Postal Code equals to "00000"
    # TODO: DRY
    Given the buyer has valid credit card with lots of money

    When the buyer logs in to the provider
    And go to the braintree edit credit card details page
    Then I should be at url for the braintree edit credit card details page

    When I fill in the braintree credit card form
    And I fill in "ZIP / Postal Code" with "00000"
    And I press "Save details"
    Then I should see "Credit card details were successfully stored."
