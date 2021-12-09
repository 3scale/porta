@javascript
Feature: Metric creation
  In order to track various metrics of my API
  As a provider
  I want to create them

  Background:
    Given a provider "foo.3scale.localhost"
    And an application plan "Basic" of provider "foo.3scale.localhost"
    When current domain is the admin domain of provider "foo.3scale.localhost"
    And I log in as provider "foo.3scale.localhost"

  Scenario: Create a metric from the service definition page
    When I go to the service definition page
    And I follow "Add a metric"
    And I fill in "Friendly name" with "Number of zombies killed"
    And I fill in "System name" with "zombie_kills"
    And I fill in "Unit" with "corpses"
    And I fill in "Description" with "How many zombies the user killed"
    And I press "Create Metric"

    Then provider "foo.3scale.localhost" should have metric "zombie_kills"
      And metric "zombie_kills" should have the following:
        | Friendly name | Number of zombies killed         |
        | Unit          | corpses                          |
        | Description   | How many zombies the user killed |

    And current domain is the admin domain of provider "foo.3scale.localhost"
    When I log in as provider "foo.3scale.localhost"
      And I go to the edit page for plan "Basic"
    Then I should see metric "Number of zombies killed"

