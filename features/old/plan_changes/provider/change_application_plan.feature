@javascript
Feature: Change Application Plan
  In order to fullfill special requirements of my clients
  As a provider
  I want to change their application plan

  Background:
    Given a published plan "Pro" of provider "Master account"
    And a provider "foo.3scale.localhost" signed up to plan "Pro"

    And a default application plan "Basic" of provider "foo.3scale.localhost"
    And a application plan "Advanced" of provider "foo.3scale.localhost"

    And a buyer "bob" of provider "foo.3scale.localhost"
    And buyer "bob" has application "app"

    And all the rolling updates features are off

  @ignore-backend
  Scenario: Change application plan
   Given current domain is the admin domain of provider "foo.3scale.localhost"
     And I log in as provider "foo.3scale.localhost"
     And I go to the provider side "app" application page

    When I select "Advanced" from "Change plan"
     And I press "Change plan"
    Then I should see "Plan changed to 'Advanced'"
     And I log out

    When I act as "bob"
    Then I should receive an email with subject "Application plan changed to 'Advanced'"


