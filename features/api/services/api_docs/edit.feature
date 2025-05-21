@javascript
Feature: Product edit ActiveDocs page

  As a provider, I want to be able to update my ActiveDocs specs.

  Background:
    Given a provider is logged in
    And a product

  Scenario Outline: Navigation from index
    Given the product has a <swagger version> spec "Echo API"
    When they go to the ActiveDocs page
    And select action "Edit" of "Echo API"
    Then the current page is spec "Echo API" edit page from Product context

    Examples:
      | swagger version |
      | Swagger 1.2     |
      | Swagger 2       |
      | OAS 3.0         |

  Scenario Outline: Navigation from preview
    Given the product has a <swagger version> spec "Echo API"
    When they go to the spec's preview page from Product context
    And follow "Edit"
    Then the current page is spec "Echo API" edit page from Product context

    Examples:
      | swagger version |
      | Swagger 1.2     |
      | Swagger 2       |
      | OAS 3.0         |

  Scenario Outline: Update a spec
    Given the product has a <swagger version> spec "Echo API"
    And a product "New service"
    When they go to the spec's edit page from Product context
    And the form is submitted with:
      | Name                     | Echo API 2              |
      | Publish?                 | Yes                     |
      | Description              | This is a very nice API |
      | Service                  | New service             |
      | API JSON Spec            | { "todo": "yes" }       |
      | Skip swagger validations | Yes                     |
    Then they should see a toast alert with text "ActiveDocs Spec was successfully updated"

    Examples:
      | swagger version |
      | Swagger 1.2     |
      | Swagger 2       |
      | OAS 3.0         |

  Scenario Outline: Required fields
    Given the product has a <swagger version> spec "Echo API"
    When they go to the spec's edit page from Product context
    Then there is a required field "Name"
    And there is a readonly field "System name"
    And there is a required field "API JSON Spec"

    Examples:
      | swagger version |
      | Swagger 1.2     |
      | Swagger 2       |
      | OAS 3.0         |

  Scenario Outline: API JSON Spec validation
    Given the product has a <swagger version> spec "Echo API"
    When they go to the spec's edit page from Product context
    And the form is submitted with:
      | API JSON Spec | invalid |
    Then field "API JSON Spec" has inline error "Invalid JSON"
    When the form is submitted with:
      | API JSON Spec | { "swagger": "5" } |
    Then field "API JSON Spec" has inline error "Invalid Swagger version"
    When the form is submitted with:
      | API JSON Spec | { "swagger": "foo" } |
    Then field "API JSON Spec" has inline error "JSON Spec is invalid"

    Examples:
      | swagger version |
      | Swagger 1.2     |
      | Swagger 2       |
      | OAS 3.0         |
