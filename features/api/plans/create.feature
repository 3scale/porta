@javascript
Feature: Plan creation
  In order to offer my client different features and usage conditions
  As a provider
  I want to create different plans for them

  Background:
    Given a provider "foo.3scale.localhost"
    And current domain is the admin domain of provider "foo.3scale.localhost"
    And I log in as provider "foo.3scale.localhost"

    Scenario: Create simple application plan
      And I go to the application plans admin page
      And I follow "Create Application plan"
      And I fill in "Name" with "Basic"
      And I press "Create Application Plan"
      Then I should be at url for the application plans admin page
