@emails @audit
Feature: Sign Up of enterprise buyers
  In order to use API of one of 3scale's clients
  As a buyer
  I want to sign up, activate and login

  Background:
    Given a provider "foo.3scale.localhost"
    And the following account plan:
      | Issuer               | Name   | Default |
      | foo.3scale.localhost | Tier-1 | true    |
      And a default service of provider "foo.3scale.localhost" has name "api"
    And the following service plan:
      | Product | Name | Default |
      | api     | Gold | true    |
    And the following application plan:
      | Product | Name   | Default | State     |
      | api     | iPhone | true    | Published |
      And the current domain is foo.3scale.localhost

  # regression test for https://github.com/3scale/system/pull/2902
  Scenario: Wrong activation code
    When I visit a invalid activation link as a buyer
    Then I should see "Activation error"

   Scenario: (Enterprise, Single App Mode) Plain signup, activate and login
      And provider "foo.3scale.localhost" has multiple applications disabled

     When I go to the sign up page
      And I fill in the signup fields as "hugo"
     Then I should see the registration succeeded
      But user "hugo" should be pending

    When I follow the activation link in an email sent to "hugo@3scale.localhost"
    Then I should see "Signup complete. You can now sign in."
     And user "hugo" should be active

   Then the account "hugo's stuff" should have an account contract with the plan "Tier-1"
    And the account "hugo's stuff" should have a service contract
    And the account "hugo's stuff" should have a application contract
    And account "hugo's stuff" should be buyer

  Scenario: Choose application plan, the rest is default
    Given provider "foo.3scale.localhost" has multiple applications disabled
    When I go to the sign up page for the "iPhone" plan
    Then I should see "You are signing up to plan iPhone."
     And I fill in the signup fields as "hugo"
     Then I should see the registration succeeded
      And account "hugo's stuff" should be buyer
