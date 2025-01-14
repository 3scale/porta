@javascript
Feature: BackendApi > Metrics index > Metric
  In Order to change a plan
  As a provider
  I should be able to delete a metric

  Background:
    Given a provider is logged in
    And a backend api with the following metrics:
      | Pizza |
    And a backend api with the following methods:
      | Margherita  |
    And I go to the metrics and methods page of my backend api

  Scenario: Delete a method
    When I change to tab 'Methods'
    And I follow "Margherita"
    And I press "Delete"
    And confirm the dialog
    Then I should not see metric "Margherita"

  Scenario: Delete a metric
    When I change to tab 'Metrics'
    And I follow "Pizza"
    And I press "Delete"
    And confirm the dialog
    Then I should not see metric "Pizza"

  Scenario: Default metric can't be deleted
    When I change to tab 'Metrics'
    And I follow "Hits"
    Then I should not see "Delete"
