@javascript
Feature: Plan creation
  In order to offer my client different features and usage conditions
  As a provider
  I want to create different plans for them

  Background:
    Given a provider is logged in

  Scenario: Create simple service plan
    Given the provider has "service_plans" switch allowed
    When I go to the service plans admin page
    And I follow "Create service plan"
    And I fill in "Name" with "Basic"
    And I press "Create Service plan"
    Then I should be at url for the service plans admin page

  Scenario: Edit service plan name
    Given the provider has "service_plans" switch allowed
    Given a service plan "Pro" of provider "foo.3scale.localhost"
    And I go to the service plans admin page
    And I follow "Pro"
    And I fill in "Name" with "Enterprise"
    And I press "Update Service plan"
    Then I should be at url for the service plans admin page
    And I should see plan "Enterprise"
    But I should not see plan "Pro"

  # regression test: https://github.com/3scale/system/pull/3368/files
  Scenario: Correct service on edit service plan
    Given the provider has "service_plans" switch allowed
    And a service "Pocoyo" of provider "foo.3scale.localhost"
    And a default published service plan "Pocoyo service plan" of service "Pocoyo" of provider "foo.3scale.localhost"
    When an admin is on the service plans page of product "Pocoyo"
    And I follow "Pocoyo service plan"
    Then I should see "Pocoyo"
