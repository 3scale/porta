@javascript
Feature: Product > Metrics index
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

  Scenario: Default tab is methods
    Then I should see the following methods:
      | Margherita  |
      | Diavola     |
      | Carbonara   |
      | Amatriciana |

  Scenario: Change tab to metrics
    And I press "Metrics"
    Then I should see the following metrics:
      | Hits  |
      | Pizza |
      | Pasta |

  Scenario: New method button
    Then I should see "Add a method"

  Scenario: New metrics button
    And press "Metrics"
    Then I should see "Add a metric"
