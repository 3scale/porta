Feature: Dev Portal Buyer Payment Details
  In order to pay for the service
  As a buyer
  I want to enter my billing and credit card details and keep them up to date

  Background:
    Given a buyer logged in to a provider
    And the provider is charging
    And the provider has prepaid billing enabled
    And the provider has "finance" switch visible

  # Scenario: The provider is charging and the plan has a fee but the buyer can't see Payment details in Settings

  Rule: Billing disabled

    Background:
      Given the provider is not charging
      And the provider has prepaid billing disabled
      And the provider has "finance" switch denied

    Scenario: Credit card details are not available
      When the buyer is reviewing their account details
      Then the buyer can't add or update their credit card details

  @stripe
  Rule: Billing with Stripe

    Background:
      Given the provider manages payments with "stripe"

    Scenario: Legal Links on Credit Card Details edit page on Enterprise
      Given the provider has the following settings:
        | cc_terms_path   | lorem-terms   |
        | cc_privacy_path | ipsum-privacy |
        | cc_refunds_path | dolor-refunds |
      When the buyer is reviewing their credit card details
      Then links to Terms of service, Privacy and Refund policies should be visible

    Scenario: Update credit card details
      # TODO: FIXME: HACK: the following step is needed, otherwise the test fails because stripe tries to send
      # a request to the API. I wonder if having this step renders this scenario useless. We should mock the
      # request and try update the credit card data, not only the billing address fields
      Given the buyer has a valid credit card
      When the buyer is reviewing their account settings
      Then the buyer can update their credit card details

  @braintree @javascript
  Rule: Braintree

    Background:
      Given the provider has testing credentials for braintree
      # provider billing with Braintree ?

    Scenario: Legal Links on Credit Card Details edit page on Enterprise
      Given the provider has the following settings:
        | cc_terms_path   | lorem-terms   |
        | cc_privacy_path | ipsum-privacy |
        | cc_refunds_path | dolor-refunds |
      When the buyer is reviewing their credit card details
      Then links to Terms of service, Privacy and Refund policies should be visible
    @chrome
    Scenario: Add credit card details
      Given the buyer has not yet added credit card details
      When the buyer is reviewing their account settings
      Then the buyer can add their credit card details

    Scenario: Update credit card details
      Given the buyer has already added credit card details
      When the buyer is reviewing their account settings
      Then the buyer can update their credit card details
