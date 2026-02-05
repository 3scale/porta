Feature: Buyer password reset
  I want to reset my password as a buyer

  Background:
    Given a provider exists

  Rule: ReCAPTCHA protects from bots
    Background:
      Given the provider has bot protection enabled for its buyers

    @recaptcha
    Scenario: Bot protection doesn't detect the client as a bot
      Given the client will be marked as a bot
      When the buyer wants to reset their password
      And the buyer fills in the form
      Then the page should contain "Bot protection failed."

    @recaptcha
    Scenario: Bot protection doesn't detect the client as a bot
      Given the client won't be marked as a bot
      When the buyer wants to reset their password
      And the buyer fills in the form
      Then the page should contain "A password reset link will be sent"

  Rule: Reset password flow for different scenarios
    Background:
      Given a buyer "bob" signed up to the provider
      And an active user "zed" of account "bob" with email "zed@3scale.localhost"
      And the current domain is foo.3scale.localhost
      And they go to the login page

    Scenario: Reset password of an existing user
      Given they follow "Forgot password?"
      And they fill in "Email" with "zed@3scale.localhost"
      And they press "Send instructions"
      Then they should see "A password reset link will be sent to zed@3scale.localhost if a user exists with this email"
      When they follow the link found in the password reset email send to "zed@3scale.localhost"
      And they fill in "Password" with "superSecret1234#"
      And they fill in "Password confirmation" with "superSecret1234#"
      And they press "Change Password"
      Then they should see "The password has been changed"

      When they go to the login page
      And they fill in "Username" with "zed@3scale.localhost"
      And they fill in "Password" with "superSecret1234#"
      And they press "Sign in"
      Then they should be logged in as "zed"

    Scenario: Invalid email
      Given no user exists with an email of "bob@3scale.localhost"
      And they follow "Forgot password?"
      And they fill in "Email" with "bob@3scale.localhost"
      And they press "Send instructions"
      Then they should see "A password reset link will be sent to bob@3scale.localhost if a user exists with this email"
      And "bob@3scale.localhost" should receive no emails

    Scenario: Wrong confirmation
      Given they follow "Forgot password?"
      And they fill in "Email" with "zed@3scale.localhost"
      And they press "Send instructions"
      And they follow the link found in the password reset email send to "zed@3scale.localhost"
      And they fill in "Password" with "new_password_123"
      And they fill in "Password confirmation" with "123_new_password"
      And they press "Change Password"
      Then they should see the password confirmation error
      And the password of user "zed" should not be "new_password_123"

    Scenario: Blank passwords
      When they follow "Forgot password?"
      And they fill in "Email" with "zed@3scale.localhost"
      And they press "Send instructions"
      And they follow the link found in the password reset email send to "zed@3scale.localhost"
      And they press "Change Password"
      Then they should see "The password is invalid"

    Scenario: Invalid token
      When they go to the password page with invalid password reset token
      Then they should see "The password reset token is invalid"

    Scenario: Attempt to login with invalid credentials, then reset password
      Given they fill in "Username" with "zed@3scale.localhost"
      And they fill in "Password" with "ihavenoclue"
      And they press "Sign in"
      Then they should see "Incorrect email or password. Please try again"
      When they follow "Forgot password?"
      And they fill in "Email" with "zed@3scale.localhost"
      And they press "Send instructions"
      Then they should see "A password reset link will be sent to zed@3scale.localhost if a user exists with this email"
