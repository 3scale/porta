@javascript
Feature: BackendApi > Metrics index
  In order to control the way my buyers are using my API
  As a provider
  I want to see their methods and metrics

  Background:
    Given a provider is logged in
    And a backend api with the following metrics:
      | Pizza  |
      | Pasta  |
    And a backend api with the following methods:
      | Margherita  |
      | Diavola     |
      | Carbonara   |
      | Amatriciana |
    And I go to the metrics and methods page of my backend api

  Rule: Tab methods
    Scenario: Default tab is methods
      Then I should see the following methods:
        | Margherita  |
        | Diavola     |
        | Carbonara   |
        | Amatriciana |

    Scenario: New method button
      Then I should see "Add a method"

    Scenario: Create a method
      Given I follow "Add a method"
      And I fill in "Friendly name" with "Cotto e Funghi"
      And I fill in "System name" with "cotto-e-funghi"
      When I press "Create Method"
      Then I should see "Cotto e Funghi"

    Scenario: Methods and mapping rules
      Given method "Diavola" is not mapped
      And method "Carbonara" is mapped
      When I change to tab "Methods"
      Then I should be able to add a mapping rule to "Diavola"
      But I should see "Carbonara" already mapped

  Rule: Tab metrics
    Background:
      Given I change to tab "Metrics"

    Scenario: Metrics table
      Then I should see the following metrics:
        | Hits  |
        | Pizza |
        | Pasta |

    Scenario: New metrics button
      Then I should see "Add a metric"

    Scenario: Create a metric
      Given I follow "Add a metric"
      And I fill in "Friendly name" with "Antipasti"
      And I fill in "System name" with "Antipasti"
      And I fill in "Unit" with "servings"
      When I press "Create Metric"
      Then I should see "Antipasti"

    Scenario: Metrics and mapping rules
      Given metric "Pizza" is not mapped
      And metric "Pasta" is mapped
      When I change to tab "Metrics"
      Then I should be able to add a mapping rule to "Pizza"
      But I should see "Pasta" already mapped
