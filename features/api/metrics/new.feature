@javascript
Feature: Product > Integration > Metrics > New
  Background:
    Given a provider is logged in
    And a product "My API"

  Rule: Navigation
    Background:
      Given they go to the provider dashboard
      And follow "My API" within the apis dashboard widget
      And press "Integration" within the main menu
      And follow "Methods and Metrics" within the main menu

    Scenario: Navigating to new method page
      When tab "Methods" is selected
      And follow "Add a method"
      Then the current page is the new method page of product "My API"

    Scenario: Navigating to new metric page
      When tab "Metrics" is selected
      And follow "Add a metric"
      Then the current page is the new metric page of product "My API"

  Rule: Tab methods
    Background:
      Given they go to the new method page of product "My API"

    Scenario: Creating a method
      When the form is submitted with:
        | Friendly name | Cotto e Funghi         |
        | System name   | cotto_funghi           |
        | Description   | Number of times served |
      Then they should see the following table:
        | Method         | System name  | Unit | Description            |
        | Cotto e Funghi | cotto_funghi | hit  | Number of times served |
      And should see a toast alert with text "The method was created"

    Scenario: Creating a method with existing data
      Given the product has the following method:
        | Friendly name | System name | Description      |
        | Cotoletta     | cotoletta   | Thin and crunchy |
      When the form is submitted with:
        | Friendly name | Cotoletta        |
        | System name   | cotoletta        |
        | Description   | Thin and crunchy |
      Then field "Friendly name" has inline error "has already been taken"
      And field "System name" has inline error "has already been taken"
      But field "Description" has no inline error

  Rule: Tab metrics
    Background:
      Given they go to the new metric page of product "My API"

    Scenario: Creating a metric
      When the form is submitted with:
        | Friendly name | Antipasti        |
        | System name   | antipasti        |
        | Unit          | order            |
        | Description   | Number of orders |
      Then they should see the following table:
        | Metric    | System name | Unit  | Description        | Mapped             |
        | Hits      | hits        | hit   | Number of API hits |                    |
        | Antipasti | antipasti   | order | Number of orders   | Add a mapping rule |
      And should see a toast alert with text "The metric was created"

    Scenario: Creating a metric with existing data
      Given the product has the following metric:
        | Friendly name | System name | Unit    | Description   |
        | Carni         | carni       | serving | Orders served |
      When the form is submitted with:
        | Friendly name | Carni         |
        | System name   | carni         |
        | Unit          | serving       |
        | Description   | Orders served |
      Then field "Friendly name" has inline error "has already been taken"
      And field "System name" has inline error "has already been taken"
      But field "Unit" has no inline error
      But field "Description" has no inline error
