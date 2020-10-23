@emails @javascript
Feature: Emails
  As a provider
  I want to control email notifications like a boss

Scenario: Disable 'Suspend Application' notification
  Given a provider "foo.3scale.localhost" with default plans
    And provider "foo.3scale.localhost" has multiple applications enabled
    And provider "foo.3scale.localhost" has email template "cinstance_messenger_suspended"
    """
    {% email %}{% do_not_send %}{% endemail %}
    """

   When a buyer "bob" signed up to provider "foo.3scale.localhost"
    And I am logged in as provider "foo.3scale.localhost" on its admin domain

    And buyer "bob" has application "other"
    And I go to the provider side "other" application page
    Then I should see that application "other" is live
    When I follow "Suspend" and I confirm dialog box
    Then application "other" should be suspended

    And I act as "bob"
    Then I should receive no email with subject "Application has been suspended"

Scenario: Disable 'Waiting list confirmation' notification
    Given a provider "foo.3scale.localhost" with default plans
    And provider "foo.3scale.localhost" requires accounts to be approved
    And provider "foo.3scale.localhost" has multiple applications enabled
    And provider "foo.3scale.localhost" has email template "account_confirmed"
    """
    {% email %}{% do_not_send %}{% endemail %}
    Dear More Things,

    This email is to let you know that you own even more things.
    """

    When the current domain is "foo.3scale.localhost"
    And I go to the sign up page
    And I fill in the signup fields as "Kirill"
    Then I should see the registration succeeded

    When I follow the activation link in an email sent to "Kirill@3scale.localhost"
    Then I should see "once your account is approved"

    When I act as "Kirill"
    Then I should receive no email with subject "Waiting list confirmation"

Scenario: Disable 'Waiting list confirmation' notification with truthy condition
    Given a provider "foo.3scale.localhost" with default plans
    And provider "foo.3scale.localhost" requires accounts to be approved
    And provider "foo.3scale.localhost" has multiple applications enabled
    And provider "foo.3scale.localhost" has email template "account_confirmed"
    """
    {% if true %}{% email %}{% do_not_send %}{% endemail %}{% endif %}
    Dear More Things,

    This email is to let you know that you own even more things.
    """

    When the current domain is "foo.3scale.localhost"
    And I go to the sign up page
    And I fill in the signup fields as "Kirill"
    Then I should see the registration succeeded

    When I follow the activation link in an email sent to "Kirill@3scale.localhost"
    Then I should see "once your account is approved"

    When I act as "Kirill"
    Then I should receive no email with subject "Waiting list confirmation"

Scenario: Disable 'Waiting list confirmation' notification with falsy condition
    Given a provider "foo.3scale.localhost" with default plans
    And provider "foo.3scale.localhost" requires accounts to be approved
    And provider "foo.3scale.localhost" has multiple applications enabled
    And provider "foo.3scale.localhost" has email template "account_confirmed"
    """
    {% if false %}{% email %}{% do_not_send %}{% endemail %}{% endif %}
    Dear More Things,

    This email is to let you know that you own even more things.
    """

    When the current domain is "foo.3scale.localhost"
    And I go to the sign up page
    And I fill in the signup fields as "Kirill"
    Then I should see the registration succeeded

    When I follow the activation link in an email sent to "Kirill@3scale.localhost"
    Then I should see "once your account is approved"

    When I act as "Kirill"
    Then I should receive 1 email with subject "Waiting list confirmation"

Scenario: Custom email subject with truthy condition
    Given a provider "foo.3scale.localhost" with default plans
    And provider "foo.3scale.localhost" requires accounts to be approved
    And provider "foo.3scale.localhost" has multiple applications enabled
    And provider "foo.3scale.localhost" has email template "account_confirmed"
    """
    {% if true %}
      {% email %}
        {% subject 'Your account has been confirmed' %}
      {% endemail %}
    {% else %}
      {% email %}
        {% subject 'Other custom subject' %}
      {% endemail %}
    {% endif %}
    Dear More Things,

    This email is to let you know that you own even more things.
    """

    When the current domain is "foo.3scale.localhost"
    And I go to the sign up page
    And I fill in the signup fields as "Kirill"
    Then I should see the registration succeeded

    When I follow the activation link in an email sent to "Kirill@3scale.localhost"
    Then I should see "once your account is approved"

    When I act as "Kirill"
    Then I should receive no email with subject "Waiting list confirmation"
    And I should receive no email with subject "Other custom subject"
    Then I should receive 1 email with subject "Your account has been confirmed"

Scenario: Custom email subject with falsy condition
    Given a provider "foo.3scale.localhost" with default plans
    And provider "foo.3scale.localhost" requires accounts to be approved
    And provider "foo.3scale.localhost" has multiple applications enabled
    And provider "foo.3scale.localhost" has email template "account_confirmed"
    """
    {% if false %}
      {% email %}
        {% subject 'Your account has been confirmed' %}
      {% endemail %}
    {% else %}
      {% email %}
        {% subject 'Other custom subject' %}
      {% endemail %}
    {% endif %}
    Dear More Things,

    This email is to let you know that you own even more things.
    """

    When the current domain is "foo.3scale.localhost"
    And I go to the sign up page
    And I fill in the signup fields as "Kirill"
    Then I should see the registration succeeded

    When I follow the activation link in an email sent to "Kirill@3scale.localhost"
    Then I should see "once your account is approved"

    When I act as "Kirill"
    Then I should receive no email with subject "Waiting list confirmation"
    And I should receive no email with subject "Your account has been confirmed"
    Then I should receive 1 email with subject "Other custom subject"

Scenario: Do not disable 'Waiting list confirmation' notification due to falsy condition but still change the subject
    Given a provider "foo.3scale.localhost" with default plans
    And provider "foo.3scale.localhost" requires accounts to be approved
    And provider "foo.3scale.localhost" has multiple applications enabled
    And provider "foo.3scale.localhost" has email template "account_confirmed"
    """
    {% if false %}
      {% email %}
        {% do_not_send %}
      {% endemail %}
    {% else %}
      {% email %}
        {% subject 'Your account has been confirmed' %}
      {% endemail %}
    {% endif %}
    Dear More Things,

    This email is to let you know that you own even more things.
    """

    When the current domain is "foo.3scale.localhost"
    And I go to the sign up page
    And I fill in the signup fields as "Kirill"
    Then I should see the registration succeeded

    When I follow the activation link in an email sent to "Kirill@3scale.localhost"
    Then I should see "once your account is approved"

    When I act as "Kirill"
    Then I should receive no email with subject "Waiting list confirmation"
    And I should receive 1 email with subject "Your account has been confirmed"
