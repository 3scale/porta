@javascript
Feature: Product > Integration > Metrics index
  In order to control the way my buyers are using my API
  As a provider
  I want to see their methods and metrics

  Background:
    Given a provider is logged in
    And the following metrics:
      | Pizza  |
      | Pasta  |
    And the following methods:
      | Margherita  |
      | Diavola     |
      | Carbonara   |
      | Amatriciana |
    And I go to the metrics and methods page

  Rule: Tab methods
    Scenario: Default tab is methods
      Then I should see the following methods:
        | Margherita  |
        | Diavola     |
        | Carbonara   |
        | Amatriciana |

    Scenario: New method button
      Then I should see "Add a method"

    Scenario: Methods and mapping rules
      Given method "Diavola" is not mapped
      And method "Carbonara" is mapped
      When I change to tab "Methods"
      Then I should be able to add a mapping rule to "Diavola"
      But I should not be able to add a mapping rule to "Carbonara"

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

    Scenario: Metrics and mapping rules
      Given metric "Pizza" is not mapped
      And metric "Pasta" is mapped
      When I change to tab "Metrics"
      Then I should be able to add a mapping rule to "Pizza"
      But I should not be able to add a mapping rule to "Pasta"
