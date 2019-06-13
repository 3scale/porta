Feature: Account Plan Change
  In order to fullfill special requirements of my clients
  As a provider
  I want to change their plan

  Background:
    Given a published plan "Pro" of provider "Master account"
    And a provider "foo.example.com" signed up to plan "Pro"

    And a published account plan "Basic" of provider "foo.example.com"
    And a published account plan "Advanced" of provider "foo.example.com"

    And provider "foo.example.com" has "account_plans" visible

    And a buyer "bob" signed up to account plan "Basic"

  Scenario: Change account plan
     And current domain is the admin domain of provider "foo.example.com"
     And I log in as provider "foo.example.com"

     And I go to the buyer account page for "bob"
    Then I should see "Change Plan"
    When I select "Advanced" from "account_contract_plan_id"
      And I press "Change"
    Then I should see "Plan changed to 'Advanced'"
