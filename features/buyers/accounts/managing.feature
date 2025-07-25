@javascript
Feature: Accounts management
  As a provider
  I want manage my accounts

  Background:
    Given a provider is logged in
    And a buyer "Alexander"
    And there are no events

  Scenario: Delete account events
    Given admin of account "foo.3scale.localhost" has notification "account_deleted" enabled
    When the provider deletes the account named "Alexander"
      Then there should be 1 valid account deleted event
      # TODO
      # service contract cancelled event should not be send
      # And there should be 0 valid service contract cancelled event
      And all the events should be valid
      And the users should receive the account deleted notification email
