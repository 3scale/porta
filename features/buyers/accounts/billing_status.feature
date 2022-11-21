Feature: Admin Portal Buyer's Billing Status
  In order to know as much as I can about my clients
  As a provider
  I want to see their blling status

  Background:
    Given a provider is logged in
    And the provider is charging its buyers
    And the provider has a buyer with application

  Scenario: Buyer do not have payment details
    Given the admin is reviewing one of their buyer's details
    Then they should see the credit card is not stored

  Scenario: Buyer has added payment details
    Given the buyer has a valid credit card
    Given the admin is reviewing one of their buyer's details
    Then they should see the credit card is stored
