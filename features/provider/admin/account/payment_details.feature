Feature: Provider Payment Details
  In order to pay for the service
  As a provider
  I want to enter my payment details and keep them up to date

  Rule: Master provider
    Scenario: Master provider cannot enter payment details
      Given master admin is logged in
      Then the provider's payment details are not accessible

  @javascript
  Rule: Provider
    Background:
      Given a provider is logged in
      And a valid account

    Scenario: Payment details cannot be added without a valid payment gateway
      Given the master provider has not configured a payment gateway
      When reviewing the provider's payment details
      Then the provider's payment details can't be added

    Scenario: Payment details cannot be added without a valid account
      Given an invalid account
      When reviewing the provider's payment details
      Then the provider's payment details can be added only after completing account information

    Scenario: Legal Links on payment details edit page
      Given the master provider has the following settings:
        | cc_terms_path   | lorem-terms   |
        | cc_privacy_path | ipsum-privacy |
        | cc_refunds_path | dolor-refunds |
      When reviewing the provider's payment details
      Then they should see Terms of service, Privacy and Refund policies

    Scenario: Adding payment details
      Given the master provider has configured a payment gateway
      When an admin is reviewing the provider's payment details
      And the admin will add a valid credit card
      Then the provider's payment details can be added

    Scenario: Adding a wrong credit card
      Given the master provider has configured a payment gateway
      When an admin is reviewing the provider's payment details
      But the admin will add an invalid credit card
      Then the provider's payment details can't be stored because the card number is invalid

    Scenario: Adding payment details but there is a customer mismatch
      Given the master provider has configured a payment gateway
      When an admin is reviewing the provider's payment details
      And the admin will add a valid credit card
      But there is a customer id mismatch
      Then the provider's payment details can't be stored because something went wrong

    Scenario: Updating payment details
      Given the master provider has configured a payment gateway
      And an admin has already set the provider's payment details
      When reviewing the provider's payment details
      Then the admin can edit the provider's payment details

    Scenario: Removing payment details
      Given the master provider has configured a payment gateway
      And an admin has already set the provider's payment details
      When reviewing the provider's payment details
      Then an admin can remove the provider's payment details
