@javascript
Feature: Product > ActiveDocs spec preview page

  As a provider, I want a preview page to see what my ActiveDocs spec will look like and to manage
  it.

  Background:
    Given a provider is logged in
    And a product

  Scenario Outline: Navigation
    Given the product has a <swagger version> spec "Echo API"
    When they go to the product's ActiveDocs page
    And follow "Echo API"
    Then the current page is the spec's preview page from Product context

    Examples:
      | swagger version |
      | Swagger 1.2     |
      | Swagger 2       |
      | OAS 3.0         |

  Scenario Outline: Hide the spec
    Given the product has a <swagger version> spec "Echo API"
    And the spec is published
    When they go to the spec's preview page from Product context
    And follow "Hide"
    Then they should see a toast alert with text "Spec Echo API is now hidden"
    And there should be a link to "Publish"

    Examples:
      | swagger version |
      | Swagger 1.2     |
      | Swagger 2       |
      | OAS 3.0         |

  Scenario Outline: Publish the spec
    Given the product has a <swagger version> spec "Echo API"
    And the spec is not published
    When they go to the spec's preview page from Product context
    And follow "Publish"
    Then they should see a toast alert with text "Spec Echo API is now visible"
    And there should be a link to "Hide"

    Examples:
      | swagger version |
      | Swagger 1.2     |
      | Swagger 2       |
      | OAS 3.0         |

  Scenario Outline: Delete the spec
    Given the product has a <swagger version> spec "Echo API"
    When they go to the spec's preview page from Product context
    And follow "Delete"
    And confirm the dialog
    # FIXME: it should be the product's ActiveDocs page
    Then the current page is the ActiveDocs page
    And they should not see "Echo API"

    Examples:
      | swagger version |
      | Swagger 1.2     |
      | Swagger 2       |
      | OAS 3.0         |

  Scenario Outline: Autocomplete
    Given the product has a <swagger version> spec "Echo API"
    When they go to the spec's preview page from Product context
    Then the swagger autocomplete should work for "user_key" with "user_keys"

    Examples:
      | swagger version |
      | Swagger 1.2     |
      | Swagger 2       |
    # | OAS 3.0         | Feature not implemented |

  Scenario Outline: Slashes generated curl command for header values
    Given the product has a <swagger version> spec "Echo API"
    When they go to the spec's preview page from Product context
    Then <swagger version> should escape properly the curl string

    Examples:
      | swagger version |
      | Swagger 1.2     |
      | Swagger 2       |
    # | OAS 3.0         | Feature not implemented |

