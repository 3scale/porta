Feature: Dev Portal Buyer Payment Details
  In order to pay for the service
  As a buyer
  I want to enter my billing and credit card details and keep them up to date

  Background:
    Given a buyer logged in to a provider

  Scenario: Finance is disabled
    Given the provider is charging its buyers
    But the provider has "finance" denied
    When the buyer is reviewing their account settings
    Then the buyer can't add or update any billing information

  Scenario: Finance is hidden
    Given the provider is charging its buyers
    But the provider has "finance" hidden
    When the buyer is reviewing their account details
    Then the buyer can't add or update any billing information

  Rule: Stripe

    Background:
      Given the provider is charging its buyers with stripe
      And the provider has "finance" visible

    Scenario: Legal Links on Credit Card Details edit page on Enterprise
      Given the provider has the following settings:
        | cc_terms_path   | lorem-terms   |
        | cc_privacy_path | ipsum-privacy |
        | cc_refunds_path | dolor-refunds |
      When the buyer is reviewing their credit card details
      Then the buyer should be able to see Terms of service, Privacy and Refund policies

    Scenario: Buyer adds billing information for the first time
      Given the buyer has not yet added their billing address
      When the buyer is reviewing their account settings
      Then the buyer can add their billing address for the first time for stripe
      But credit card information still needs to be added

    Scenario: Buyer cannot add a credit card if billing address not provided
      Given the buyer has already added their billing address
      When the buyer is reviewing their account details
      Then the buyer can't add their credit card

    Scenario: Buyer adds their credit card
      Given the buyer has already added their billing address
      But the buyer has not yet added their credit card details
      When the buyer is reviewing their account settings
      Then the buyer can add their credit card for stripe

    Scenario: Buyer reviews their billing information
      Given the buyer has already added their billing address
      And the buyer has already added their credit card details
      When the buyer is reviewing their account settings
      Then the buyer can see their billing information

    Scenario: Buyer updates their billing address
      Given the buyer has already added their billing address
      And the buyer has already added their credit card details
      When the buyer is reviewing their account settings
      Then the buyer can update their billing address for stripe

    @wip
    Scenario: Buyer updates their credit card
      Given the buyer has already added their billing address
      And the buyer has already added their credit card details
      When the buyer is reviewing their account settings
      Then the buyer can update their credit card

    Scenario: Buyer is redirected to Stripe payment gateway url
      When the buyer enters the generic credit card details URL manually
      Then the buyer should be redirected to the stripe page

    Scenario: Buyer adds an incomplete billing address
      Given the buyer has not yet added their billing address
      When the buyer is reviewing their account settings
      Then the buyer can't add an incomplete billing address for stripe

  Rule: Braintree

    Background:
      Given the provider is charging its buyers with braintree
      And the provider has "finance" visible

    Scenario: Legal Links on Credit Card Details edit page on Enterprise
      Given the provider has the following settings:
        | cc_terms_path   | lorem-terms   |
        | cc_privacy_path | ipsum-privacy |
        | cc_refunds_path | dolor-refunds |
      When the buyer is reviewing their credit card details
      Then the buyer should be able to see Terms of service, Privacy and Refund policies

    @javascript
    Scenario: Buyer adds billing information for the first time
      Given the buyer has not yet added their billing address
      When the buyer is reviewing their account settings
      Then the buyer can add their credit card and billing address for Braintree for the first time

    @javascript
    Scenario: Buyer adds their credit card
      Given the buyer has already added their billing address
      But the buyer has not yet added their credit card details
      When the buyer is reviewing their account settings
      Then the buyer can add their credit card and billing address for Braintree

    Scenario: Buyer reviews their billing information
      Given the buyer has already added their billing address
      And the buyer has already added their credit card details
      When the buyer is reviewing their account settings
      Then the buyer can see their billing information

    @javascript
    Scenario: Buyer updates their billing information
      Given the buyer has already added their billing address
      And the buyer has already added their credit card details
      When the buyer is reviewing their account settings
      Then the buyer can update their credit card and billing address for Braintree

    Scenario: Buyer is redirected to Braintree payment gateway url
      When the buyer enters the generic credit card details URL manually
      Then the buyer should be redirected to the braintree page
