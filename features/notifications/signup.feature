@javascript @allow-rescue
Feature: Notifications
  As a provider
  I'd like to get notified when my users do something.

  Scenario: Provider Signup Notification
    Given the master account allows signups
    And admin of account "Master account" has notification "account_created" enabled
    And admin of account "Master account" has notification "application_created" enabled
    And admin of account "Master account" has notification "service_contract_created" enabled
    When a provider signs up and activates his account
      Then the master should have plenty of notifications
      And the provider should not have any notifications
