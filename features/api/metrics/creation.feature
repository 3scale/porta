@javascript
Feature: Product > Integration > Metrics index > Metric
  In order to track various metrics of my API
  As a provider
  I want to create them

  Background:
    Given a provider is logged in
    And I go to the metrics and methods page

  Scenario: Create a method from the index page
    Given I change to tab "Methods"
    And I follow "Add a method"
    When I fill in "Friendly name" with "Cotto e Funghi"
    And I fill in "System name" with "cotto-e-funghi"
    And I fill in "Description" with "The number of times this dish has been served"
    And I press "Create Method"
    Then I should see "Cotto e Funghi"
    And the provider should have metric "Cotto e Funghi"
    And method "Cotto e Funghi" should have the following:
      | Friendly name | Cotto e Funghi                                |
      | Unit          | hit                                           |
      | Description   | The number of times this dish has been served |

  Scenario: Create a metric from the index page
    Given I change to tab "Metrics"
    And I follow "Add a metric"
    When I fill in "Friendly name" with "Antipasti"
    And I fill in "System name" with "antipasti"
    And I fill in "Unit" with "order"
    And I fill in "Description" with "The number of antipasti dishes ordered"
    And I press "Create Metric"
    Then I should see "Antipasti"
    And the provider should have metric "Antipasti"
    And metric "Antipasti" should have the following:
      | Friendly name | Antipasti                              |
      | Unit          | order                                  |
      | Description   | The number of antipasti dishes ordered |
