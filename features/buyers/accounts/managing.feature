@javascript @selenium
Feature: Accounts management
  As a provider
  I want manage my accounts

  Background:
    Given a provider is logged in
    And has a buyer with service plan
    And there are no events

  Scenario: Delete account events
    When the provider deletes the account named "Alexander"
      Then there should be 1 valid account deleted event
      # TODO
      # service contract cancelled event should not be send
      # And there should be 0 valid service contract cancelled event
      And all the events should be valid
      And the users should receive the account deleted notification email
