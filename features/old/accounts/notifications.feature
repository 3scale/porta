@javascript
Feature: Notifications
  In order to get notified by email only about the event I'm interested in
  As admin of an account
  I want to configure notifications

  Background:
    Given a provider
      And all the rolling updates features are off

  Scenario: Navigate to notifications page
    And current domain is the admin domain of provider "foo.example.com"
    When I log in as provider "foo.example.com"

    And I follow "Account"
    And I follow "Notifications"
    Then I should see "Email Notifications" in a header


  Scenario: Notifications default values
    And current domain is the admin domain of provider "foo.example.com"
    When I log in as provider "foo.example.com"

      And I go to the notifications page
    Then the "New user signup" checkbox should be checked
      And the "Receiving a new message" checkbox should be checked
      And the "Plan change by a user" checkbox should be checked
      And the "User cancels account" checkbox should be checked

    But the "New forum post" checkbox should not be checked
      And the "Weekly aggregate report" checkbox should not be checked
      And the "Daily aggregate report" checkbox should not be checked

  # This scenario was unDRYed from an Outline due to performance reasons, it went from ~2 minutes to 20 seconds
  @ajax
  Scenario: Enable notification
    And current domain is the admin domain of provider "foo.example.com"
    When I log in as provider "foo.example.com"
      And I go to the notifications page

    When I check "New user signup"
    Then I should have the notification "New user signup" enabled
    When I uncheck "New user signup"
    Then I should have the notification "New user signup" disabled

    When I check "New application created"
    Then I should have the notification "New application created" enabled
    When I uncheck "New application created"
    Then I should have the notification "New application created" disabled

    When I check "Application suspended"
    Then I should have the notification "Application suspended" enabled
    When I uncheck "Application suspended"
    Then I should have the notification "Application suspended" disabled

    When I check "Application key created"
    Then I should have the notification "Application key created" enabled
    When I uncheck "Application key created"
    Then I should have the notification "Application key created" disabled

    When I check "Application key deleted"
    Then I should have the notification "Application key deleted" enabled
    When I uncheck "Application key deleted"
    Then I should have the notification "Application key deleted" disabled

    When I check "Receiving a new message"
    Then I should have the notification "Receiving a new message" enabled
    When I uncheck "Receiving a new message"
    Then I should have the notification "Receiving a new message" disabled

    When I check "Plan change by a user"
    Then I should have the notification "Plan change by a user" enabled
    When I uncheck "Plan change by a user"
    Then I should have the notification "Plan change by a user" disabled

    When I check "New forum post"
    Then I should have the notification "New forum post" enabled
    When I uncheck "New forum post"
    Then I should have the notification "New forum post" disabled

    When I check "User cancels account"
    Then I should have the notification "User cancels account" enabled
    When I uncheck "User cancels account"
    Then I should have the notification "User cancels account" disabled

    When I check "Weekly aggregate reports"
    Then I should have the notification "Weekly aggregate reports" enabled
    When I uncheck "Weekly aggregate reports"
    Then I should have the notification "Weekly aggregate reports" disabled

    When I check "Daily aggregate reports"
    Then I should have the notification "Daily aggregate reports" enabled
    When I uncheck "Daily aggregate reports"
    Then I should have the notification "Daily aggregate reports" disabled

