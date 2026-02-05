@javascript
Feature: Provider password reset
  In order to sign in even if I forgot my password
  As a user
  I should be able to reset it

  Background:
    Given a provider

  Rule: On master domain

    Background:
      Given current domain is the master domain of the provider

    @allow-rescue
    Scenario: Reset password
      When they go to the provider login page
      Then it should not be possible to reset their password

  Rule: On provider domain

    Background:
      Given an active user "Pepe" of account "foo.3scale.localhost" with email "pepe@example.com"
      And they go to the provider reset password page

    Scenario: Reset password
      Given they go to the provider login page
      When follow "Forgot password?"
      Then the current page is the provider reset password page

    Scenario: Form validation
      When they fill in "Email" with "pepe"
      Then the submit button is disabled
      When they fill in "Email" with "pepe@example"
      Then the submit button is disabled
      When they fill in "Email" with "pepe@example.com"
      Then the submit button is enabled

    Scenario: Reset password of existing account
      When they fill in "Email" with "pepe@example.com"
      And press "Reset password"
      Then they should see "We sent an email with password reset instructions to: pepe@example.com"
      Then the current page is the provider login page

    Scenario: Reset password of unknown account
      When they fill in "Email" with "unknown@not.valid"
      And press "Reset password"
      Then they should see "We sent an email with password reset instructions to: unknown@not.valid"
      Then the current page is the provider login page

    Scenario: Set a new password
      Given the user has requested a new password
      And follow the link found in the provider password reset email send to "pepe@example.com"
      And they fill in "Password" with "superSecret1234#"
      And they fill in "Password confirmation" with "superSecret1234#"
      And press "Change Password"
      Then they should see "The password has been changed"
      And the current page is the provider login page
      And the user is now able to sign in with password "superSecret1234#"

    Scenario: New password form validation
      Given the user has requested a new password
      And follow the link found in the provider password reset email send to "pepe@example.com"
      And they fill in "Password" with "superSecret1234#"
      And they fill in "Password confirmation" with ""
      Then the submit button is disabled
      When they fill in "Password confirmation" with "superSecret1234#5"
      Then the submit button is disabled
      When they fill in "Password confirmation" with "superSecret1234#"
      Then the submit button is enabled

    Scenario: Invalid password reset token
      Given they go to the provider password page with invalid password reset token
      Then they should see "The password reset token is invalid"

    Scenario: Password reset token expires after 1 day
      Given time flies to 12th June 2009
      And the user has requested a new password
      When time flies to 14th June 2009
      And follow the link found in the provider password reset email send to "pepe@example.com"
      Then they should see "The password reset token is invalid"

    Scenario: Reuse a password reset token
      Given the user has requested a new password
      And follow the link found in the provider password reset email send to "pepe@example.com"
      And they fill in "Password" with "superSecret1234#"
      And they fill in "Password confirmation" with "superSecret1234#"
      When press "Change Password"
      Then they should see "The password has been changed"
      When follow the link found in the provider password reset email send to "pepe@example.com"
      Then they should see "The password reset token is invalid"
