# TODO: move other related test here from features/old/finance
@javascript @braintree
Feature: Provider Payment Details
  In order to pay for the service
  As a provider
  I want to enter my payment details and keep them up to date

  Background:
    # Given the time is 1st June 2009
    # And a provider is logged in
    # And the provider has valid personal details
    # But the provider doesn't have billing address
    # And master provider has billing enabled
    Given master is billing tenants
    And master provider has testing credentials for braintree

  Scenario: Master provider cannot enter payment details
    Given master admin is logged in
    Then the provider's payment details are not accessible

  Scenario: Payment details cannot be added without a valid payment gateway
    Given the provider has unconfigured payment gateway
    And an admin wants to add payment details
    Then the provider's payment details can't be added

  Scenario: Legal Links on payment details edit page
    Given master provider has the following settings:
      | cc_terms_path   | lorem-terms   |
      | cc_privacy_path | ipsum-privacy |
      | cc_refunds_path | dolor-refunds |
    When reviewing the provider's payment details
    Then links to Terms of service, Privacy and Refund policies should be visible

  Scenario: Adding payment details
    Given an admin wants to add payment details
    And the admin will add a valid credit card
    Then the provider's payment details can be added

  Scenario: Adding a wrong credit card (Braintree returns an error)
    Given an admin wants to add payment details
    But the admin will add an invalid credit card
    Then the provider's payment details can't be stored

  Scenario: Updating payment details
    Given the provider has already set payment details
    When reviewing the provider's payment details
    Then the admin can edit the provider's payment details

  Scenario: Removing payment details
    Given the provider has already set payment details
    When reviewing the provider's payment details
    Then an admin can remove the provider's the payment details
