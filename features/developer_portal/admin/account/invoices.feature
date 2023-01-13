Feature: Dev Portal Buyer Invoices
  In order not be confused
  As a buyer
  I don't want to see any invoices if I my provider does not support it

  Background:
    Given a buyer logged in to a provider

  Scenario: Provider has charging enabled
    Given the provider is charging its buyers
    And the provider has "finance" visible
    When the buyer is reviewing their account settings
    Then they should be able to see their invoices
    And the buyer should receive some emails after a month

  Scenario: Provider has charging disabled
    Given the provider has "finance" denied
    When the buyer is reviewing their account settings
    Then they should not be able to see any invoices
    And the buyer should receive no emails after a month
