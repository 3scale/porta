@emails @javascript @ajax
Feature: Emails
  As a provider
  I want to control email notifications like a boss

Scenario: Disable 'Suspend Application' notification
  Given a provider "foo.example.com" with default plans
    And provider "foo.example.com" has multiple applications enabled
    And provider "foo.example.com" has email template "cinstance_messenger_suspended"
    """
    {% email %}{% do_not_send %}{% endemail %}
    """

   When a buyer "bob" signed up to provider "foo.example.com"
    And I am logged in as provider "foo.example.com" on its admin domain

    And buyer "bob" has application "other"
    And I go to the provider side "other" application page
    Then I should see that application "other" is live
    When I follow "Suspend"
    Then application "other" should be suspended

    And I act as "bob"
    Then I should receive no email with subject "Application has been suspended"

Scenario: Disable 'Waiting list confirmation' notification
    Given a provider "foo.example.com" with default plans
    And provider "foo.example.com" requires accounts to be approved
    And provider "foo.example.com" has multiple applications enabled
    And provider "foo.example.com" has email template "account_confirmed"
    """
    {% email %}{% do_not_send %}{% endemail %}
    Dear More Things,

    This email is to let you know that you own even more things.
    """

    When the current domain is foo.example.com
    And I go to the sign up page
    And I fill in the signup fields as "Kirill"
    Then I should see the registration succeeded

    When I follow the activation link in an email sent to "Kirill@example.com"
    Then I should see "once your account is approved"

    When I act as "Kirill"
    Then I should receive no email with subject "Waiting list confirmation"
