Feature: Admin Portal Provider's Plan Settings
  In order to manage provider accounts
  As a master
  I want to be able to change its plan settings

  Background:
    Given a provider exists

  Rule: Finance switch

    Scenario: Finance module is allowed
      Given the provider has "finance" allowed
      When a master admin is reviewing the provider's account
      Then "Finance" should be hidden

    Scenario: Finance module is denied
      Given the provider has "finance" denied
      When a master admin is reviewing the provider's account
      Then "Finance" should be denied

    Scenario: Enabling finance module
      Given the provider has "finance" denied
      When a master admin is reviewing the provider's account
      Then "Finance" can be enabled
      And the provider should be able to access billing
