Feature: Provider Charging & Gateway settings
  In order to accept payments from my users
  As a provider
  I want to set up my payment gateway

  Background:
    Given a provider is logged in

  Scenario: Finance switched off
    Given the provider has "finance" denied
    Then they should not be able to review the charging and gateway billing settings

  Scenario: Providers have charging disabled by default
    Given the provider has "finance" allowed
    When they are reviewing the charging and gateway billing settings
    Then payment gateway cannot be set

  @javascript
  Scenario: Using Stripe as payment gateway
    Given the provider is charging its buyers
    But the provider doesn't have a payment gateway set up
    When they are reviewing the charging and gateway billing settings
    Then Stripe can be set as a payment gateway

  @javascript
  Scenario: Using Braintree as payment gateway
    Given the provider is charging its buyers
    But the provider doesn't have a payment gateway set up
    When they are reviewing the charging and gateway billing settings
    Then Braintree can be set as a payment gateway

  Scenario: Member user with access to both finance and charging
    Given an active user has access to admin section finance
    And the provider is charging its buyers
    When the user logs in
    And they are reviewing the charging and gateway billing settings
    Then payment gateway can be set

  Scenario: Member user with access to finance but not charging
    Given an active user has access to admin section finance
    And the provider is billing but not charging
    When the user logs in
    And they are reviewing the charging and gateway billing settings
    Then payment gateway cannot be set

  Scenario: Member user without access to neither finance nor charging
    Given an active user don't have access to admin section finance
    And the provider is charging its buyers
    When the user logs in
    Then they should not be able to review the charging and gateway billing settings

  Scenario: Member user with access to finance but finance is switched off
    Given an active user has access to admin section finance
    And the provider has "finance" denied
    When the user logs in
    Then they should not be able to review the charging and gateway billing settings

  Scenario: Member user without access to finance and provider not charging
    Given an active user don't have access to admin section finance
    And the provider is billing but not charging
    When the user logs in
    Then they should not be able to review the charging and gateway billing settings

  Scenario: Member user without access to finance and provider has finance switched off
    Given an active user don't have access to admin section finance
    And the provider has "finance" denied
    When the user logs in
    Then they should not be able to review the charging and gateway billing settings

  Scenario: Admin sets charging on
    Given the provider is billing but not charging
    When they are reviewing the charging and gateway billing settings
    Then charging can be enabled

  Scenario: Admin sets a currency
    Given the provider has "finance" allowed
    When they are reviewing the charging and gateway billing settings
    Then they can set a different currency to be charged
    And buyers will receive new invoices with that currency

  Scenario: Changing to yearly charging won't alter previous invoices
    Given the provider is charging its buyers
    And a buyer has been billed monthly
    When they are reviewing the charging and gateway billing settings
    Then they can set the billing period to yearly
    And only new invoices will change their id

  Scenario: Provider using a supported payment gateway
    Given the provider is charging its buyers with a supported payment gateway
    When they are reviewing the charging and gateway billing settings
    Then they should not be warned about the payment gateway being deprecated

  Scenario: Provider using a deprecated payment gateway
    Given the provider is charging its buyers with a deprecated payment gateway
    When they are reviewing the charging and gateway billing settings
    Then they should be warned about the payment gateway being deprecated
