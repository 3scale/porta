Feature: Account Plan Change
  In order to have a fake feeling of free will
  As a buyer
  I want to be able to change account plan

  Background:
    Given a published plan "Pro" of provider "Master account"
    And a provider "foo.example.com" signed up to plan "Pro"

    # there have to be at least 2 published plans for buyer to see the functionality
    # even if the switch is on 'visible'
    And provider "foo.example.com" has "account_plans" visible
    And a published account plan "Basic" of provider "foo.example.com"
    And a published account plan "Advanced" of provider "foo.example.com"

    And a buyer "bob" signed up to account plan "Basic"

  Scenario: Direct plan change
   Given provider "foo.example.com" allows to change account plan directly
    When I log in as "bob" on "foo.example.com"
     And I go to the account plans page

     And I select "Advanced" from "View plan"
     And I press invisible "Change Plan"
    Then I should see "Plan was successfully changed to Advanced"

  Scenario: Request plan change by email
   Given provider "foo.example.com" allows to change account plan by request
    When I log in as "bob" on "foo.example.com"
     And I go to the account plans page
     And I select "Advanced" from "View plan"
     And I press invisible "Request Plan Change"
    Then I should see "The plan change has been requested."

  Scenario: Credit card dependent change plan policy
   Given provider "foo.example.com" allows to change account plan only with credit card
    When I log in as "bob" on "foo.example.com"
     And I go to the account plans page
     And I select "Advanced" from "View plan"
     And I press invisible "Request Plan Change"
    Then I should see "The plan change has been requested."

    Given buyer "bob" has valid credit card with lots of money
     And I go to the account plans page
     And I select "Advanced" from "View plan"
     And I press invisible "Change Plan"
    Then I should see "Plan was successfully changed to Advanced"


  Scenario: No plan change when the functionality is disabled
   Given provider "foo.example.com" does not allow to change account plan
    When I log in as "bob" on "foo.example.com"
     And I go to the account plans page
    Then I should not see "Change plan"
    And I should see "Your Plan"
