@emails
Feature: Signup with invitation
  In order to obtain access to the system
  As someone who received an invitation
  I want to use it to sign up

  Background:
      And a provider "foo.example.com"
      And current domain is the admin domain of provider "foo.example.com"

  Scenario: Receiving an invitation, signing up and signing in
     Given the admin domain of provider "foo.example.com" is "admin.foo.example.com"
     When an invitation from account "foo.example.com" sent to "bob@foo.example.com"
      And I follow the link to signup in the invitation sent to "bob@foo.example.com"
      Then I should see the signup page
      And the "Email" field should contain "bob@foo.example.com"
    When I fill in "Username" with "bob"
      And I fill in "Password" with "monkey"
      And I fill in "Password confirmation" with "monkey"
      And I press "Sign up"
    Then I should see "Thanks for signing up! You can now sign in."
      And the current domain should be the admin domain of provider "foo.example.com"
      But "bob@foo.example.com" should receive no email with subject "Account Activation"
    When I fill in "Username" with "bob"
      And I fill in "Password" with "monkey"
      And I press "Sign in"
    Then I should be logged in as "bob"

  @javascript
  Scenario: Provider invitation is in his admin domain
    Given the admin domain of provider "foo.example.com" is "admin.foo.example.com"
    When an invitation from account "foo.example.com" sent to "bob@foo.example.com"
      And I follow the link to signup in the invitation sent to "bob@foo.example.com"
      And I press "Sign up"
    Then the current domain should be the admin domain of provider "foo.example.com"

  # provider
  Scenario: Attempting to sign up with invalid invitation token
    When current domain is the admin domain of provider "foo.example.com"
    When I go to the provider user signup page with invalid invitation token
    Then I should see "Not found"

  # buyer
  Scenario: Attempting to sign up with invalid invitation token
    When the current domain is "foo.example.com"
    When I go to the account signup page with invalid invitation token
    
    Then I should see "Invitation token did not exist."
