@javascript
Feature: Metric update
  In order to change my metrics for whatever reason
  As a provider
  I want to be able to modify them

  Background:
    Given a provider "foo.3scale.localhost"
    And a metric "nukes" with friendly name "Nukes deployed" of provider "foo.3scale.localhost"
    And current domain is the admin domain of provider "foo.3scale.localhost"

  Scenario: Can't change system name of default metric
    When I log in as provider "foo.3scale.localhost"
    And I go to the service definition page
    And I follow "Hits"
    Then I should not see field "metric[system_name]"

  # TODO: redirect update/new/delete metric to tab metrics
  Scenario: Change some fields from the service definition page
    When I log in as provider "foo.3scale.localhost"
    And I go to the service definition page
    And I follow "Nukes deployed"
    And I fill in "Friendly name" with "Number of atomic bombs dropped"
    And I fill in "Unit" with "drops"
    And I press "Update Metric"
    Then I should see "Number of atomic bombs dropped"
    And metric "nukes" should have the following:
      | Friendly name | Number of atomic bombs dropped |
      | Unit          | drops                          |
