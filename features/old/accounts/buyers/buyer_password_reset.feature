Feature: Buyer password reset
  In order to sign in even if I forgot my password
  As a user
  I should be able to reset it

  Background:
    Given a provider "foo.example.com"
    And a buyer "bob" signed up to provider "foo.example.com"
    And an active user "zed" of account "bob" with email "zed@example.com"
   When the current domain is foo.example.com
    And I go to the login page

  Scenario: Reset password
    Given I follow "Forgot password?"
    And I fill in "Email" with "zed@example.com"
    And I press "Send instructions"
    Then I should see "A password reset link has been emailed to you."
    When I follow the link found in the password reset email send to "zed@example.com"
    And I fill in "Password" with "monkey"
    And I fill in "Password confirmation" with "monkey"
    And I press "Change Password"
    Then I should see "The password has been changed"

    When I go to the login page
    And I fill in "Username" with "zed@example.com"
    And I fill in "Password" with "monkey"
    And I press "Sign in"
    Then I should be logged in as "zed"

  Scenario: Invalid email
    Given no user exists with an email of "bob@example.com"
    And I follow "Forgot password?"
    And I fill in "Email" with "bob@example.com"
    And I press "Send instructions"
    Then I should see "Email not found."

  Scenario: Wrong confirmation
    Given I follow "Forgot password?"
    And I fill in "Email" with "zed@example.com"
    And I press "Send instructions"
    And I follow the link found in the password reset email send to "zed@example.com"
    And I fill in "Password" with "monkey"
    And I fill in "Password confirmation" with "donkey"
    And I press "Change Password"
    Then I should see the password confirmation error
    And the password of user "zed" should not be "monkey"

  Scenario: Blank passwords
    When I follow "Forgot password?"
    And I fill in "Email" with "zed@example.com"
    And I press "Send instructions"
    And I follow the link found in the password reset email send to "zed@example.com"
    And I press "Change Password"
    Then I should see "The password is invalid"

  Scenario: Invalid token
    When I go to the password page with invalid password reset token
    Then I should see "The password reset token is invalid"

  Scenario: Attempt to login with invalid credentials, then reset password
    Given I fill in "Username" with "zed@example.com"
    And I fill in "Password" with "ihavenoclue"
    And I press "Sign in"
    Then I should see "Incorrect email or password. Please try again."
    When I follow "Forgot password?"
    And I fill in "Email" with "zed@example.com"
    And I press "Send instructions"
    Then I should see "A password reset link has been emailed to you."
