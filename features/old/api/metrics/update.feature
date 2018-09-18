Feature: Metric update
  In order to change my metrics for whatever reason
  As a provider
  I want to be able to modify them

  Background:
    Given a provider "foo.example.com"
    And a metric "nukes" with friendly name "Nukes deployed" of provider "foo.example.com"
    And current domain is the admin domain of provider "foo.example.com"

  Scenario: Can't change system name of default metric
    When I log in as provider "foo.example.com"
    And I go to the service definition page
    And I follow "Hits"
    Then I should not see field "metric[system_name]"

  Scenario: Change some fields from the service definition page
    When I log in as provider "foo.example.com"
    And I go to the service definition page
    And I follow "Nukes deployed"
    And I fill in "Friendly name" with "Number of atomic bombs dropped"
    And I fill in "metric[system_name]" with "bombs"
    And I fill in "Unit" with "drops"
    And I press "Update Metric"
    Then I should see "Number of atomic bombs dropped"
    And metric "bombs" should have the following:
      | Friendly name | Number of atomic bombs dropped |
      | Unit          | drops                          |
