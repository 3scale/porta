@javascript
Feature: Product > Integration > Metrics index > Metric
  In Order to change a plan
  As a provider
  I should be able to delete a metric

  Background:
    Given a provider is logged in
    And the following metrics:
      | Pasta |
    And the following methods:
      | Carbonnara |
    And I go to the metrics and methods page

  Scenario: Delete a method from the index page
    Given I change to tab "Methods"
    When I follow "Carbonnara"
    And I press "Delete" and I confirm dialog box
    Then I should not see metric "Carbonnara"
    And the provider should not have metric "Cabonnara"

  Scenario: Delete a metric from the index page
    Given I change to tab "Metrics"
    When I follow "Pasta"
    And I press "Delete" and I confirm dialog box
    Then I should not see metric "Pasta"
    And the provider should not have metric "Pasta"

  Scenario: Default metric can't be deleted
    Given I change to tab "Metrics"
    When I follow "Hits"
    Then I should not see "Delete"
