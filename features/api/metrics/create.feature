@javascript
Feature: Product > Integration > Metrics > New
  In order to track various metrics of my API
  As a provider
  I want to create them

  Background:
    Given a provider is logged in
    And I go to the metrics and methods page

  Rule: Tab methods
    Background:
      Given I change to tab "Methods"
      And I follow "Add a method"

    Scenario: Create a method with an existing system name
      Given a method "Cotoletta" of the provider
      When I fill in "Friendly name" with "Cotoletta 2"
      And I fill in "System name" with "cotoletta"
      And I press "Create Method"
      Then the provider should not have a metric "Cotoletta 2"

    Scenario: Create a method with an existing friendly name
      Given a method "Cotoletta" of the provider
      When I fill in "Friendly name" with "Cotoletta"
      And I fill in "System name" with "cotoletta_2"
      And I press "Create Method"
      Then the provider should have a metric with system name "cotoletta_2"

    Scenario: Create a method from the index page
      And I fill in "Description" with "The number of times this dish has been served"
      And I press "Create Method"
      Then I should see "Cotto e Funghi"
      And the provider should have a metric "Cotto e Funghi"
      And method "Cotto e Funghi" should have the following attributes:
        | Friendly name | Cotto e Funghi                                |
        | Unit          | hit                                           |
        | Description   | The number of times this dish has been served |

  Rule: Tab metrics
    Background:
      Given I change to tab "Metrics"
      And I follow "Add a metric"

    Scenario: Create a metrics with an existing system name
      Given a metric "Carni" of the provider
      When I fill in "Friendly name" with "Carni 2"
      And I fill in "System name" with "carni"
      And I press "Create Metric"
      Then the provider should not have a metric "Carni 2"

    Scenario: Create a metric with an existing friendly name
      Given a metric "Carni" of the provider
      When I fill in "Friendly name" with "Carni"
      And I fill in "System name" with "carni_2"
      And I press "Create Metric"
      Then the provider should have a metric with system_name "carni_2"

    Scenario: Create a metric from the index page
      When I fill in "Friendly name" with "Antipasti"
      And I fill in "System name" with "antipasti"
      And I fill in "Unit" with "order"
      And I fill in "Description" with "The number of antipasti dishes ordered"
      And I press "Create Metric"
      Then I should see "Antipasti"
      And the provider should have a metric "Antipasti"
      And metric "Antipasti" should have the following attributes:
        | Friendly name | Antipasti                              |
        | Unit          | order                                  |
        | Description   | The number of antipasti dishes ordered |
