@javascript
Feature: Backend Usages
  In order to manage my Backends
  As a provider
  I want to see a menu that lets me add Backends to a Product

  Background:
    Given a provider "foo.3scale.localhost"
    And current domain is the admin domain of provider "foo.3scale.localhost"
    And a backend api
    And I log in as provider "foo.3scale.localhost"
    And I go to the provider dashboard
    And I go to the service backends admin page of service "API"

  Scenario: Add a backend api that is unused
    Given I should see "Backends"
    And I follow "Add Backend"
    Then I should see "Add a Backend"
    And I select "My Backend" from "Backend"
    And I fill in "Path" with "/api/v1"
    And I press "Add to Product"
    Then I should see "Backend added to Product."
    Then I follow "Add Backend"
    And the "Backend" select should not contain "My Backend" option

  Scenario: Add a backend with wrong path
    Given I follow "Add Backend"
    And I select "My Backend" from "Backend"
    And I fill in "Path" with "https://my-api.exaple.org"
    And I press "Add to Product"
    Then I should see "Couldn't add Backend to Product"

  Scenario: Add a backend must be accessible
    Given an admin wants to add an unaccessible backend
    Then only accessible backends will be available
