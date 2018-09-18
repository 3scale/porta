@javascript @selenium
Feature: Applications management
  As a provider
  I want manage my applications

  Background:
    Given a provider is logged in
      And the provider has a buyer with application
      And there are no events

  Scenario: Delete application events
    When the provider deletes the application
      Then there should be 1 valid cinstance cancellation event
      And all the events should be valid
      And the users should receive the application has been deleted notification email
