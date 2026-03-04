@emails
Feature: Buyer signup to service allowing multiple applications per buyer
  In order to use API of one of 3scale's clients
  As a buyer
  I want to sign up

  Background:
    Given a provider "foo.3scale.localhost" with default plans
    And provider "foo.3scale.localhost" has "multiple_applications" visible
    And provider "foo.3scale.localhost" requires cinstances to be approved before use
    And provider "foo.3scale.localhost" requires accounts to be approved
    # TODO: add scenario without default app plan
    And the current domain is foo.3scale.localhost

  Scenario: Signup, activate, approve and login
    When I go to the sign up page
    Then I should be on the sign up page

    When I fill in "Username" with "hugo"
    And I fill in "Email" with "hugo@stuff.com"
    And I fill in "Organization/Group Name" with "hugo's stuff"
    And I fill in "Password" with "superSecret1234#"
    And I fill in "Password confirmation" with "superSecret1234#"
    And I press "Sign up"
    Then I should see "Please click the link in the email and you can directly login!"
    When I follow the activation link in an email sent to "hugo@stuff.com"
    Then I should see "You will receive a message once your account is approved"

    And buyer "hugo's stuff" should be pending
    When buyer "hugo's stuff" is approved

    And I fill in "Username" with "hugo"
    And I fill in "Password" with "superSecret1234#"
    And I press "Sign in"
    Then I should be logged in as "hugo"


  Scenario: Attempt to sign up with Invalid details
    When I go to the sign up page
    And the form is submitted with:
      | Username |  |
    And I should see error "is too short (minimum is 3 characters)" for field "Username"
