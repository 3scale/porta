@javascript
Feature: Master finance settings
  As a master I don't want to be able to see services in the Dashboard or the Context Selector

  Background:
    Given the master account admin has username "master" and password "supersecret"
    And a provider "foo.3scale.localhost"

  Scenario: No APIs widgets
    When I am logged in as master admin on master domain
    And I go to the provider dashboard
    Then I should not see "Products"
    And I should not see "Backends"

  Scenario: No Products or Backends in Context Selector
    When I am logged in as master admin on master domain
    And I go to the provider dashboard
    And I open the Context Selector
    Then I should not see link "Products" within the Context Selector
    And I should not see link "Backends" within the Context Selector
