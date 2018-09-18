Feature: Copy plan
  In order to allow easier transition of buyers to different plan
  As a provider
  I want to make an exact copy of the plan

  Background:
    Given a provider "foo.example.com"
      And provider "foo.example.com" uses backend v2 in his default service
      And provider "foo.example.com" has multiple applications enabled

      And a buyer "bob" signed up to provider "foo.example.com"
      And current domain is the admin domain of provider "foo.example.com"
      And I am logged in as provider "foo.example.com"


  @javascript
  Scenario: Copy account plan
    Given provider "foo.example.com" has "account_plans" switch allowed
    And an account plan "Basic" of provider "foo.example.com"
    When I go to the account plans admin page
    And I follow "Copy plan 'Basic'"
    Then I should see "Plan copied."
    And I should see "Basic (copy)"
    And I should see only one default plan selector

  @javascript
  Scenario: Copy application plan
    And an application plan "Basic" of provider "foo.example.com"
    When I go to the application plans admin page
    And I follow "Copy plan 'Basic'"
    Then I should see "Plan copied."
    And I should see "Basic (copy)"
    And I should see only one default plan selector
   
  @javascript
  Scenario: Copy service plan
    Given a service plan "Basic" of provider "foo.example.com"
    And provider "foo.example.com" has "service_plans" visible
    When I go to the service plans admin page
    And I follow "Copy plan 'Basic'"
    Then I should see "Plan copied."
    And I should see "Basic (copy)"
    And I should see only one default plan selector
    
