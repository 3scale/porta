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

  Scenario: Enable notification
    And I go to the notifications page

    When I check "New user signup"
    Then mail dispatch rule "foo.3scale.localhost/user_signup" is set to "true"
    When I uncheck "New user signup"
    Then mail dispatch rule "foo.3scale.localhost/user_signup" is set to "false"

    When I check "New application created"
    Then mail dispatch rule "foo.3scale.localhost/new_app" is set to "true"
    When I uncheck "New application created"
    Then mail dispatch rule "foo.3scale.localhost/new_app" is set to "false"

    When I check "Application suspended"
    Then mail dispatch rule "foo.3scale.localhost/app_suspended" is set to "true"
    When I uncheck "Application suspended"
    Then mail dispatch rule "foo.3scale.localhost/app_suspended" is set to "false"

    When I check "Application key created"
    Then mail dispatch rule "foo.3scale.localhost/key_created" is set to "true"
    When I uncheck "Application key created"
    Then mail dispatch rule "foo.3scale.localhost/key_created" is set to "false"

    When I check "Application key deleted"
    Then mail dispatch rule "foo.3scale.localhost/key_deleted" is set to "true"
    When I uncheck "Application key deleted"
    Then mail dispatch rule "foo.3scale.localhost/key_deleted" is set to "false"

    When I check "Receiving a new message"
    Then mail dispatch rule "foo.3scale.localhost/new_message" is set to "true"
    When I uncheck "Receiving a new message"
    Then mail dispatch rule "foo.3scale.localhost/new_message" is set to "false"

    When I check "Plan change by a user"
    Then mail dispatch rule "foo.3scale.localhost/plan_change" is set to "true"
    When I uncheck "Plan change by a user"
    Then mail dispatch rule "foo.3scale.localhost/plan_change" is set to "false"

    When I check "New forum post"
    Then mail dispatch rule "foo.3scale.localhost/new_forum_post" is set to "true"
    When I uncheck "New forum post"
    Then mail dispatch rule "foo.3scale.localhost/new_forum_post" is set to "false"

    When I check "User cancels account"
    Then mail dispatch rule "foo.3scale.localhost/cinstance_cancellation" is set to "true"
    When I uncheck "User cancels account"
    Then mail dispatch rule "foo.3scale.localhost/cinstance_cancellation" is set to "false"

    When I check "Weekly aggregate reports"
    Then mail dispatch rule "foo.3scale.localhost/weekly_reports" is set to "true"
    When I uncheck "Weekly aggregate reports"
    Then mail dispatch rule "foo.3scale.localhost/weekly_reports" is set to "false"

    When I check "Daily aggregate reports"
    Then mail dispatch rule "foo.3scale.localhost/daily_reports" is set to "true"
    When I uncheck "Daily aggregate reports"
    Then mail dispatch rule "foo.3scale.localhost/daily_reports" is set to "false"
