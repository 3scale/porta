Feature: Change Application Plan
  In order to fullfill special requirements of my clients
  As a provider
  I want to change their application plan

  Background:
    Given a published plan "Pro" of provider "Master account"
    And a provider "foo.example.com" signed up to plan "Pro"

    And a default application plan "Basic" of provider "foo.example.com"
    And a application plan "Advanced" of provider "foo.example.com"

    And a buyer "bob" of provider "foo.example.com"
    And buyer "bob" has application "app"

    And all the rolling updates features are off

  @ignore-backend
  Scenario: Change application plan
   Given current domain is the admin domain of provider "foo.example.com"
     And I log in as provider "foo.example.com"
     And I go to the provider side "app" application page

    Then I should see "Change Plan"
    When I select "Advanced" from "cinstance_plan_id"
     And I press "Change"
    Then I should see "Plan changed to 'Advanced'"
     And I go to provider logout

    When I act as "bob"
    Then I should receive an email with subject "Application plan changed to 'Advanced'"
