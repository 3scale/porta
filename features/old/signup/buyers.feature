@emails @audit
Feature: Sign Up of enterprise buyers
  In order to use API of one of 3scale's clients
  As a buyer
  I want to sign up, activate and login

  Background:
    Given a provider "foo.example.com"
      And a account plan "Tier-1" of provider "foo.example.com"

      And a default service of provider "foo.example.com" has name "api"
      And a service plan "Gold" for service "api" exists
      And an application plan "iPhone" of service "api"

      And the current domain is foo.example.com

  # regression test for https://github.com/3scale/system/pull/2902
  Scenario: Wrong activation code
    When I visit a invalid activation link as a buyer
    Then I should see "Activation error"

   Scenario: (Enterprise, Single App Mode) Plain signup, activate and login
    Given service plan "Gold" is default
      And account plan "Tier-1" is default
      And application plan "iPhone" is default
      And provider "foo.example.com" has multiple applications disabled

     When I go to the sign up page
      And I fill in the signup fields as "hugo"
     Then I should see the registration succeeded
      But user "hugo" should be pending

    When I follow the activation link in an email sent to "hugo@example.com"
    Then I should see "Signup complete. You can now sign in."
     And user "hugo" should be active

   Then the account "hugo's stuff" should have an account contract with the plan "Tier-1"
    And the account "hugo's stuff" should have a service contract
    And the account "hugo's stuff" should have a application contract
    And account "hugo's stuff" should be buyer

  Scenario: Choose application plan, the rest is default
    Given provider "foo.example.com" has multiple applications disabled
      And service plan "Gold" is default
      And account plan "Tier-1" is default
      And plan "iPhone" is published

    When I go to the sign up page for the "iPhone" plan
    Then I should see "You are signing up to plan iPhone."
     And I fill in the signup fields as "hugo"
     Then I should see the registration succeeded
      And account "hugo's stuff" should be buyer
