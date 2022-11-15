# TODO: move other related test here from features/old/finance
@javascript
Feature: Edit Payment Details
  In order to pay for the service
  As a provider
  I want to enter my payment details and keep them up to date

  Background:
    Given the time is 1st June 2009
    And a provider is logged in
    And the provider has valid personal details
    But the provider doesn't have billing address
    And master provider has billing enabled

  Scenario: Legal Links on payment details edit page
    Given master provider has the following settings:
      | cc_terms_path   | lorem-terms   |
      | cc_privacy_path | ipsum-privacy |
      | cc_refunds_path | dolor-refunds |
    When reviewing the provider's payment details
    Then links to Terms of service, Privacy and Refund policies should be visible

  @braintree
  Rule: BraintreeBlue

    Background:
      Given master provider has testing credentials for braintree

    Scenario: Updating credit card details
      When updating the provider's payment details
      Then the credit card details can be updated

    Scenario: Adding a wrong credit card
      When updating the provider's payment details
      And trying to add a wrong credit card
      Then I should see "Credit card number is invalid"
      And I should be on the provider braintree edit credit card details page
