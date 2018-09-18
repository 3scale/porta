Feature: Provider password reset
  In order to sign in even if I forgot my password
  As a user
  I should be able to reset it

  Background:
    Given a provider "foo.example.com"
    And an active user "zed" of account "foo.example.com" with email "zed@example.com"

    Given current domain is the admin domain of provider "foo.example.com"
    When I go to the provider login page

  Scenario: Reset password
    And I follow "Forgot password?"
    And I fill in "Email" with "zed@example.com" in the request password reset form
    And I press "Reset password"
    Then I should see "A password reset link has been emailed to you."
    When I follow the link found in the provider password reset email send to "zed@example.com"
    And I fill in "Password" with "monkey"
    And I fill in "Password confirmation" with "monkey"
    And I press "Change Password"
    Then I should see "The password has been changed"

    When I go to the provider login page
    And I fill in "Username" with "zed@example.com"
    And I fill in "Password" with "monkey"
    And I press "Sign in"
    Then I should be logged in as "zed"

  Scenario: Invalid email
    Given no user exists with an email of "bob@example.com"
    And I follow "Forgot password?"
    And I fill in "Email" with "bob@example.com" in the request password reset form
    And I press "Reset password"
    Then I should see "Email not found."

  Scenario: Wrong confirmation
    When I follow "Forgot password?"
    And I fill in "Email" with "zed@example.com" in the request password reset form
    And I press "Reset password"
    And I follow the link found in the provider password reset email send to "zed@example.com"
    And I fill in "Password" with "monkey"
    And I fill in "Password confirmation" with "donkey"
    And I press "Change Password"
    Then I should see the password confirmation error
    And the password of user "zed" should not be "monkey"

  Scenario: Invalid token
    When I go to the provider password page with invalid password reset token
    Then I should see "The password reset token is invalid"

  Scenario: Expired token after 1 day
    And time flies to 12th June 2009
    When I follow "Forgot password?"
    And I fill in "Email" with "zed@example.com" in the request password reset form
    And I press "Reset password"
    And time flies to 14th June 2009
    When I follow the link found in the provider password reset email send to "zed@example.com"
    Then I should see "The password reset token is invalid"

  Scenario: Try to reuse a token
    When I follow "Forgot password?"
    And I fill in "Email" with "zed@example.com" in the request password reset form
    And I press "Reset password"
    When I follow the link found in the provider password reset email send to "zed@example.com"
    And I fill in "Password" with "monkey"
    And I fill in "Password confirmation" with "monkey"
    And I press "Change Password"
    Then I should see "The password has been changed"
    And I follow the link found in the provider password reset email send to "zed@example.com"
    Then I should see "The password reset token is invalid"


  Scenario: Attempt to login with invalid credentials, then reset password
    And I fill in "Username" with "zed@example.com"
    And I fill in "Password" with "ihavenoclue"
    And I press "Sign in"
    Then I should see "Incorrect email or password. Please try again."
    When I follow "Forgot password?"
    And I fill in "Email" with "zed@example.com" in the request password reset form
    And I press "Reset password"
    Then I should see "A password reset link has been emailed to you."
