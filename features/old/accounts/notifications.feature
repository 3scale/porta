@javascript
Feature: Notifications
  In order to get notified by email only about the event I'm interested in
  As admin of an account
  I want to configure notifications

  Background:
    Given a provider is logged in
    And all the rolling updates features are off

  Scenario: Navigate to notifications page
    And I go to the provider account page
    And I follow "Notifications"
    Then I should see "Email Notifications" in a header

  Scenario: Notifications default values
    And I go to the notifications page
    Then the "New user signup" checkbox should be checked
    And the "Receiving a new message" checkbox should be checked
    And the "Plan change by a user" checkbox should be checked
    And the "User cancels account" checkbox should be checked

    But the "New forum post" checkbox should not be checked
    And the "Weekly aggregate report" checkbox should not be checked
    And the "Daily aggregate report" checkbox should not be checked
