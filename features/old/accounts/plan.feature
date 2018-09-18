Feature: Signed up plan
  In order to have control over the plan I've signed up
  I want to be able to manage plan

  Background:
    Given a provider "foo.example.com"
      And provider "foo.example.com" has multiple applications enabled
      And provider "foo.example.com" has "account_plans" visible
    Given a buyer "buyer" signed up to provider "foo.example.com"

  Scenario: Buyers does not see plans link if only one account plan
    Given I am logged in as "buyer" on "foo.example.com"
    When I follow "Settings"
    Then I should not see the link "Plans"

  Scenario: Buyers sees plans link if there is more than 1 published account plan
    Given an account plan "published" of provider "foo.example.com"
      And an account plan "second" of provider "foo.example.com"
      And plan "published" is published
      And plan "second" is published
    Given I am logged in as "buyer" on "foo.example.com"
    When I follow "Settings"
    Then I should see the link "Plans"

    When I follow "Plans"
    Then I should see "You are currently on plan"

  #TODO plan change request scenario
