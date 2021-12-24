@javascript
Feature: Product > Integration > Metrics > Edit
  In Order to change a plan
  As a provider
  I should be able to delete a metric

  Background:
    Given a provider is logged in
    And the following metrics:
      | Pasta |
    And the following methods:
      | Carbonara |
    And I go to the metrics and methods page

  Scenario: Delete a method from the index page
    Given I change to tab "Methods"
    When I follow "Carbonara"
    And I press "Delete" and I confirm dialog box
    Then I should not see metric "Carbonara"
    And the provider should not have metric "Carbonara"

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
