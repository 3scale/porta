@javascript
Feature: Copy plan
  In order to allow easier transition of buyers to different plan
  As a provider
  I want to make an exact copy of the plan

  Background:
    Given a provider "foo.3scale.localhost"
    And provider "foo.3scale.localhost" uses backend v2 in his default service
    And provider "foo.3scale.localhost" has multiple applications enabled
    And a buyer "bob" signed up to provider "foo.3scale.localhost"
    And current domain is the admin domain of provider "foo.3scale.localhost"
    And I am logged in as provider "foo.3scale.localhost"

  Scenario: Copy account plan
    Given provider "foo.3scale.localhost" has "account_plans" switch allowed
    And an account plan "Basic" of provider "foo.3scale.localhost"
    When I go to the account plans admin page
    And I follow "Copy plan 'Basic'"
    Then I should see "Plan copied."
    And I should see "Basic (copy)"
    And I should see only one default plan selector

  Scenario: Copy application plan
    And an application plan "Basic" of provider "foo.3scale.localhost"
    When I go to the application plans admin page
    And I select option "Copy" from the actions menu for plan "Basic"
    Then I should see "Plan copied."
    And I should see "Basic (copy)"
    And I should see only one default plan selector

  Scenario: Copy service plan
    Given a service plan "Basic" of provider "foo.3scale.localhost"
    And provider "foo.3scale.localhost" has "service_plans" visible
    When I go to the service plans admin page
    And I follow "Copy plan 'Basic'"
    Then I should see "Plan copied."
    And I should see "Basic (copy)"
    And I should see only one default plan selector
