@javascript
Feature: Product's new ActiveDocs page

  As a provider, I want to add ActiveDocs specs to my API

  Background:
    Given a provider is logged in
    And a product "My API"
    And they go to the product's new ActiveDocs spec page

  Scenario Outline: Navigation with specs
    Given the product has a <swagger version> spec "My Spec"
    When they go to the product's ActiveDocs page
    And they follow "Add a new spec"
    Then the current page is the product's new ActiveDocs spec page

    Examples:
      | swagger version |
      | Swagger 1.2     |
      | Swagger 2       |
      | OAS 3.0         |

  Scenario: Navigation without specs
    Given they go to the product's ActiveDocs page
    When they follow "Create your first spec"
    Then the current page is the product's new ActiveDocs spec page

  Scenario Outline: Add a new spec
    Given there is no field "Service"
    When the ActiveDocs form is submitted with:
      | Name                     | My Spec           |
      | Publish?                 | Yes               |
      | Description              | This is an API    |
      | API JSON Spec            | <swagger version> |
      | Skip swagger validations | No               |
    Then they should see a toast alert with text "ActiveDocs Spec was successfully saved"
    And the current page is the spec's preview page from Product context

    Examples:
      | swagger version |
      | Swagger 1.2     |
      | Swagger 2       |
      | OAS 3.0         |
