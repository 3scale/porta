@javascript
Feature: Edit plans
  In order to offer my client different features and usage conditions
  As a provider
  I want to edit different plans for them

  Background:
    Given a provider "foo.3scale.localhost"
    And current domain is the admin domain of provider "foo.3scale.localhost"
    And I log in as provider "foo.3scale.localhost"

  Scenario: Edit application plan name
    Given an application plan "Pro" of provider "foo.3scale.localhost"
    And I go to the application plans admin page
    And I follow "Pro"
    And I fill in "Name" with "Enterprise"
    And I press "Update Application plan"
    Then I should be at url for the application plans admin page
    And I should see plan "Enterprise"
    But I should not see plan "Pro"
