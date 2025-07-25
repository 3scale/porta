Feature: Dev Portal Buyer Invoices
  In order not be confused
  As a buyer
  I don't want to see any invoices if I my provider does not support it

  Background:
    Given it's the beginning of the month
    And a provider
    And the default product of the provider has name "My API"
    And the following application plan:
      | Product | Name | Default | Cost per month |
      | My API  | Gold | true    | 100            |
    And an approved buyer "John" signed up to the provider
    And the following application:
      | Buyer | Name   |
      | John  | My App |
    And no emails have been sent

  Scenario: Provider has prepaid monthly charging enabled
    Given the provider is charging its buyers in prepaid mode
    And the provider has "finance" visible
    And 1 month pass
    When the buyer logs in
    And the buyer is reviewing their account settings
    Then they should have access last's month invoice
    And the buyer should receive some emails

  Scenario: Provider has charging disabled
    Given the provider has "finance" denied
    And 1 month pass
    When the buyer logs in
    And the buyer is reviewing their account settings
    Then they should not have access to invoices
    And the buyer should receive no emails
