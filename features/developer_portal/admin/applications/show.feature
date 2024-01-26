Feature: Developer portal application overview page

  Background:
    Given a provider
    And a product "The API"
    And the following published application plans:
      | Product | Name       | default |
      | The API | Enterprise |         |
      | The API | Developer  | true    |
    And a buyer "Jane" signed up to service "The API"
    And the buyer has an application "My App" for the product
    And the buyer logs in

  Scenario: Navigation
    Given they go to the homepage
    When they follow "My App"
    Then the current page is the application's dev portal page

  Scenario: Application fields visibility for buyers
    Given the provider has the following fields defined for applications:
      | Label        | Required | Read only | Hidden |
      | Phone number | true     |           |        |
      | UUID         |          | true      |        |
      | Secret sauce |          |           | true   |
    And the application has the following extra fields:
      | Phone number | 666-555-444 |
      | UUID         | 123         |
      | Secret sauce | Ketchup     |
    When they go to the application's dev portal page
    Then they should see the following details:
      | Phone number | 666-555-444 |
      | UUID         | 123         |
    But should not see "Ketchup"
