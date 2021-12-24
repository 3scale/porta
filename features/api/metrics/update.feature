@javascript
Feature: Product > Integration > Metrics > Edit
  In order to change my metrics for whatever reason
  As a provider
  I want to be able to modify them

  Background:
    Given a provider is logged in
    And the following metrics:
      | Antipasti |
    And the following methods:
      | Burrata |
    And I go to the metrics and methods page

  Scenario: Edit a method from the index page
    Given I change to tab "Methods"
    When I follow "Burrata"
    And I fill in "Friendly name" with "Burrata Panzanella"
    And I press "Update Method"
    Then I should see "Burrata Panzanella"
    And method "Burrata Panzanella" should have the following attributes:
      | Friendly name | Burrata Panzanella |
      | Unit          | hit                |

  Scenario: Can't change system name of default metric
    Given I change to tab "Metrics"
    When I follow "Hits"
    Then I should see field "System name" disabled

  Scenario: Edit a metric from the index page
    Given I change to tab "Metrics"
    When I follow "Antipasti"
    And I fill in "Friendly name" with "Carni"
    And I fill in "Unit" with "Orders"
    And I press "Update Metric"
    Then I should see "Carni"
    And metric "Carni" should have the following attributes:
      | Friendly name | Carni  |
      | Unit          | Orders |
