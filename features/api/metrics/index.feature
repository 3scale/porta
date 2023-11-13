@javascript
Feature: Product > Integration > Metrics
  Background:
    Given a provider is logged in
    And a product "My API"

  Rule: Navigation
    Background:
      Given they go to the provider dashboard
      And they follow "My API" within the apis dashboard widget
      And press "Integration" within the main menu
      And follow "Methods and Metrics" within the main menu

    Scenario: Navigating to methods tab (default tab)
      When tab "Methods" is selected
      Then the current page is the methods page of product "My API"

    Scenario: Navigating to new metric page
      When tab "Metrics" is selected
      Then the current page is the metrics page of product "My API"

  Rule: Empty states
    @wip
    Scenario: Methods empty state
      When they go to the methods page of product "My API"
      Then they should see an empty state

    Scenario: Metrics has always Hits by default
      When they go to the metrics page of product "My API"
      Then should see metric "Hits"

  Rule: Tab methods
    Background:
      And the product has the following methods:
        | Friendly name |
        | Margherita    |
        | Diavola       |

    Scenario: Methods and mapping rules
      Given method "Margherita" is mapped
      But method "Diavola" is not mapped
      When they go to the methods page of product "My API"
      Then should see "Margherita" already mapped
      And should be able to add a mapping rule to "Diavola"

    @search @wip
    Scenario: Empty search state
      Given they go to the methods page of product "My API"
      When the search "Pineapples" using the toolbar input
      Then they should see an empty search state

    @search @wip
    Scenario: Filtering methods
      Given they go to the methods page of product "My API"
      And Then they should see the following table:
        | Method     |
        | Margherita |
        | Diavola    |
      When the search "dia" using the toolbar input
      Then they should see the following table:
        | Method  |
        | Diavola |

  Rule: Tab metrics
    Background:
      And the product has the following metrics:
        | Friendly name |
        | Pizza         |
        | Pasta         |

    Scenario: Methods and mapping rules
      Given metric "Pizza" is mapped
      But metric "Pasta" is not mapped
      When they go to the metrics page of product "My API"
      Then should see "Pizza" already mapped
      And should be able to add a mapping rule to "Pasta"

    @search @wip
    Scenario: Empty search state
      Given they go to the metrics page of product "My API"
      When the search "Focaccia" using the toolbar input
      Then they should see an empty search state

    @search @wip
    Scenario: Filtering methods
      Given they go to the metrics page of product "My API"
      And Then they should see the following table:
        | Metric |
        | Pizza  |
        | Pasta  |
      When the search "piz" using the toolbar input
      Then they should see the following table:
        | Method |
        | Pizza  |
