@javascript
Feature: Product > Integration > Metrics > Edit
  Background:
    Given a provider is logged in
    And a product "My API"
    And the product has a method "Carbonara"
    And the product has a metric "Pasta"

  Rule: Methods
    Scenario: Navigation to edit method
      When they go to the methods page of product "My API"
      And follow "Carbonara"
      Then the current page is the edit page of method "Carbonara"

    Scenario: Editting a method
      Given they go to the edit page of method "Carbonara"
      And should see field "System name" disabled
      When the form is submitted with:
        | Friendly name | Aglio e oleo       |
        | Description   | Deliciously simple |
      Then they should see a toast alert with text "The method was updated"
      And should see the following table:
        | Method       | Description        |
        | Aglio e oleo | Deliciously simple |

    Scenario: Deleting a method
      Given they go to the edit page of method "Carbonara"
      When they follow "Delete"
      And confirm the dialog
      Then they should see a toast alert with text "The method was deleted"
      And should not see method "Carbonara"

  Rule: Metrics
    Scenario: Navigation to edit metric
      When they go to the metrics page of product "My API"
      And follow "Pasta"
      Then the current page is the edit page of metric "Pasta"

    Scenario: Editting a metric
      Given they go to the edit page of metric "Pasta"
      And should see field "System name" disabled
      When the form is submitted with:
        | Friendly name | Dessert            |
        | Unit          | serving            |
        | Description   | Last but not least |
      Then they should see a toast alert with text "The metric was updated"
      And should see the following table:
        | Metric  | Description        | Unit    |
        | Hits    | Number of API hits | hit     |
        | Dessert | Last but not least | serving |

    Scenario: Deleting a metric
      Given they go to the edit page of metric "Pasta"
      When they follow "Delete"
      And confirm the dialog
      Then they should see a toast alert with text "The metric was deleted"
      And should not see metric "Pasta"

    Scenario: Default metric can't be deleted
      Given they go to the edit page of metric "Hits"
      Then should not see "Delete"

    Scenario: Cannot delete a metric used in the latest gateway configuration
      Given metric "Pasta" is used in the latest gateway configuration
      When they go to the edit page of metric "Pasta"
      And follow "Delete"
      And confirm the dialog
      Then they should see a toast alert with text "Metric is used by the latest gateway configuration and cannot be deleted"
      And should see metric "Pasta"
