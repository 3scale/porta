@javascript
Feature: Metric deletion
  In Order to change a plan
  As a provider
  I should be able to delete a metric

  Background:
    Given a provider "foo.3scale.localhost"
    And a metric "transfer" of provider "foo.3scale.localhost"
    And current domain is the admin domain of provider "foo.3scale.localhost"

  Scenario: Deleting a metric from the metrics page
    When I log in as provider "foo.3scale.localhost"
    And I go to the service definition page
    And I follow "transfer"
    And I press "Delete" and I confirm dialog box
    Then I should not see metric "transfer"
    And provider "foo.3scale.localhost" should not have metric "transfer"

  Scenario: Default metric can't be deleted
    When I log in as provider "foo.3scale.localhost"
    And I go to the service definition page
    And I follow "Hits"
    Then I should not see "Delete"
