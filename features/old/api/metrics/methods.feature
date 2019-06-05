Feature: Methods
  In order to track different method calls of my API
  As a provider
  I want to define methods

  Background:
    Given a published plan "Pro" of provider "Master account"
    And plan "Pro" has "method tracking" enabled
    Given a provider "foo.example.com" signed up to plan "Pro"
    And current domain is the admin domain of provider "foo.example.com"

  @javascript
  Scenario: Create a method from the service definition page
    When I log in as provider "foo.example.com"
    And I go to the service definition page
    And I follow "New method"
    And I fill in "Friendly name" with "Search"
    And I fill in "System name" with "search"
    And I press "Create Method"
    Then I should see "Search"
