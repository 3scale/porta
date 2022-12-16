Feature: Admin Portal Buyer's Billing Status
  In order to know as much as I can about my clients
  As a provider
  I want to see their billing status

  Background:
    Given a provider is logged in
    And the provider has a buyer with an application

  Scenario: Provider with finance switched off
    Given the provider has "finance" denied
    When an admin is reviewing the buyer's account
    Then they should not see any billing status

  Scenario: Provider has charging disabled
    Given the provider has charging disabled
    When an admin is reviewing the buyer's account
    Then they should see the buyer is being billed monthly
    And monthly billing can be disabled

  Scenario: Provider has charging enabled but no payment gateway
    Given the provider has charging enabled
    But the provider doesn't have a payment gateway set up
    When an admin is reviewing the buyer's account
    Then they should see the buyer is being charged monthly
    And monthly charging can be disabled

  Rule: Provider has charging enabled and a payment gateway set up

    Background:
      Given the provider is charging its buyers

    Scenario: Buyer do not have payment details
      Given the buyer has not added their credit card details
      When an admin is reviewing the buyer's account
      Then they should see the credit card is not stored

    Scenario: Buyer has added payment details
      Given the buyer has added their credit card details
      When an admin is reviewing the buyer's account
      Then they should see the credit card is stored
