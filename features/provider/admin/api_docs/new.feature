@javascript
Feature: Audience new ActiveDocs page

  As a provider, I want to add ActiveDocs specs to any of my APIs

  Background:
    Given a provider is logged in
    And a product "My API"
    And another product "My Other API"
    And they go to the new ActiveDocs spec page

  Scenario Outline: Navigation with specs
    Given the provider has a <swagger version> spec "Echo API"
    When they go to the ActiveDocs page
    And they follow "Add a new spec"
    Then the current page is the new ActiveDocs spec page

    Examples:
      | swagger version |
      | Swagger 1.2     |
      | Swagger 2       |
      | OAS 3.0         |
      | OAS 3.1         |

  Scenario: Navigation without specs
    Given they go to the ActiveDocs page
    When they follow "Create your first spec"
    Then the current page is the new ActiveDocs spec page

  Scenario Outline: Add a new spec
    When the ActiveDocs form is submitted with:
      | Name                     | My Spec                   |
      | Publish?                 | Yes                       |
      | Description              | This is an API            |
      | Service                  | My Other API              |
      | API JSON Spec            | <swagger version>         |
      | Skip swagger validations | No                        |
    Then they should see the flash message "ActiveDocs Spec was successfully saved."
    And the current page is the spec's preview page from Product context

    Examples:
      | swagger version |
      | Swagger 1.2     |
      | Swagger 2       |
      | OAS 3.0         |
      | OAS 3.1         |

  Scenario Outline: Add a new invalid specification
    When the ActiveDocs form is submitted with:
      | Name                     | My Spec                   |
      | Publish?                 | Yes                       |
      | Description              | This is an API            |
      | Service                  | My Other API              |
      | API JSON Spec            | <swagger version>         |
      | Skip swagger validations | No                        |
    Then the current page is the ActiveDocs page
    And field "API JSON Spec" has inline error "<error>"

    Examples:
      | swagger version         | error                               |
      | invalid Swagger 1.2     | did not contain a required property |
      | invalid Swagger 2       | did not contain a required property |
      | invalid OAS 3.0         | is missing required properties      |
      | invalid OAS 3.1         | is missing required properties      |
