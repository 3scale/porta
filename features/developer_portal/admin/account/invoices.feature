Feature: Dev Portal Buyer Invoices
  In order not be confused
  As a buyer
  I don't want to see any invoices if I my provider does not support it

  Background:
    Given it's the beginning of the month
    And a buyer signed up to a provider
    And no emails have been sent

  Scenario: Provider has prepaid monthly charging enabled
    Given the provider is charging its buyers in prepaid mode
    And the provider has "finance" visible
    And 1 month pass
    When the buyer logs in to the provider
    And the buyer is reviewing their account settings
    Then they should be able to see an invoice for last month
    And the buyer should receive some emails

  Scenario: Provider has charging disabled
    Given the provider has "finance" denied
    And 1 month pass
    When the buyer logs in to the provider
    And the buyer is reviewing their account settings
    Then they should not be able to see any invoices
    And the buyer should receive no emails
