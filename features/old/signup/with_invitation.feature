@emails
Feature: Signup with invitation
  In order to obtain access to the system
  As someone who received an invitation
  I want to use it to sign up

  Background:
      And a provider "foo.3scale.localhost"
      And current domain is the admin domain of provider "foo.3scale.localhost"

  @javascript
  Scenario: Receiving an invitation, signing up with extra fields and signing in
     Given the admin domain of provider "foo.3scale.localhost" is "admin.foo.3scale.localhost"
     And master provider has the following fields defined for users:
      | name       |
      | first_name |
      | last_name  |
     When an invitation from account "foo.3scale.localhost" sent to "bob@foo.3scale.localhost"
      And I follow the link to signup in the invitation sent to "bob@foo.3scale.localhost"
      Then I should see the signup page
      And the "Email" field should contain "bob@foo.3scale.localhost"
    When I fill in "Username" with "bob"
      And I fill in "First name" with "bob"
      And I fill in "Last name" with "dole"
      And I fill in "Password" with "superSecret1234#"
      And I fill in "Password confirmation" with "superSecret1234#"
      And I press "Sign up"
    Then I should see "Thanks for signing up! You can now sign in"
      And the current domain should be the admin domain of provider "foo.3scale.localhost"
      But "bob@foo.3scale.localhost" should receive no email with subject "Account Activation"
    When I fill in "Username" with "bob"
      And I fill in "Password" with "superSecret1234#"
      And I press "Sign in"
    Then I should be logged in as "bob"
