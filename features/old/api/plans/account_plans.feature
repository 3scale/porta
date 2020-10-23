Feature: Different account plans
  To have different account plans
  As a provider
  I want to see correct links depending on my account plans switch activation

  Background:
    Given a provider "foo.3scale.localhost"
      And an application plan "power1M" of provider "master"
      And current domain is the admin domain of provider "foo.3scale.localhost"
    When I log in as provider "foo.3scale.localhost"

  Scenario: In allowed state, I should be able to do everything
    Given provider "foo.3scale.localhost" has "account_plans" switch allowed
      And I am on the provider site page
    When I follow "Accounts"
     And I follow "Account Plans"
    Then I should see the copy button

    When I follow "Create Account Plan"
      And I fill in "Name" with "second account plan"
      And I press "Create Account plan"
    Then I should see "second account plan"

  Scenario: In allowed state, but with Account Plans hidden I should not see Account Plans menu
    Given provider "foo.3scale.localhost" has "account_plans" switch allowed
      And provider has account plans hidden from the ui
      And I am on the provider site page
    When I follow "Accounts"
    Then there should not be any mention of account plans
