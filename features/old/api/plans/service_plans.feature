@javascript
Feature: API Service Plans
  To have different service plans
  As a provider
  I want to see correct links depending on my service plans switch activation

  Background:
    Given a provider "foo.example.com"
    And an application plan "pro3M" of provider "master"
    And current domain is the admin domain of provider "foo.example.com"
    When I log in as provider "foo.example.com"

  Scenario: In allowed state, I should be able to do everything
    Given provider "foo.example.com" has "service_plans" switch allowed
    When I go to the service plans admin page
    Then I should see the copy button

    When I follow "Create Service Plan"
    And I fill in "Name" with "second service plan"
    And I press "Create Service plan"
    Then I should see "second service plan"

  Scenario: In allowed state, but with Service Plans hidden I should not see Service Plans menu
    Given provider "foo.example.com" has "service_plans" switch allowed
    And provider has "service_plans_ui_visible" hidden
    And I am on the API dashboard page
    Then there should not be any mention of service plans

  Scenario: In allowed state, but with Service Plans hidden I should be able to see default plan in service settings
    Given provider "foo.example.com" has "service_plans" switch allowed
    And provider has service plans hidden from the ui
    When I go to the settings page for service "API" of provider "foo.example.com"
    Then I should see "Default Service Plan"

  Scenario: In allowed state, but with Service Plans visible I should be able to set default plan in service settings
    Given provider "foo.example.com" has "service_plans" switch allowed
    When I go to the settings page for service "API" of provider "foo.example.com"
    Then I should not see "Default Service Plan"