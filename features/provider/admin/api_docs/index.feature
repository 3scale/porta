@javascript
Feature: Audience > Developer portal > ActiveDocs

  As a provider, I want to manage all my ActiveDocs specs from all my APIs in the same page

  Background:
    Given a provider is logged in
    And a product "My API"

  Scenario: Navigation
    When they select "Audience" from the context selector
    And they press "Developer Portal" within the main menu
    And follow "ActiveDocs" within the main menu
    Then the current page is the ActiveDocs page

  Scenario: Empty view
    When they go to the ActiveDocs page
    Then there should be a link to "Create your first spec"

  Scenario: Index does show the API column
    Given the product has a Swagger 2 spec "Echo API"
    When they go to the ActiveDocs page
    Then the table should have a column "API"

  Scenario Outline: Hide the spec
    Given the product has a <swagger version> spec "Echo API"
    And the spec is published
    When they go to the ActiveDocs page
    And they select action "Hide" of "Echo API"
    Then they should see the flash message "Spec Echo API is now hidden"
    And the table has the following row:
      | Name     | State  |
      | Echo API | hidden |

    Examples:
      | swagger version |
      | Swagger 1.2     |
      | Swagger 2       |
      | OAS 3.0         |

  Scenario Outline: Publish the spec
    Given the product has a <swagger version> spec "Echo API"
    And the spec is not published
    When they go to the ActiveDocs page
    And they select action "Publish" of "Echo API"
    Then they should see the flash message "Spec Echo API is now visible"
    And the table has the following row:
      | Name     | State   |
      | Echo API | visible |

    Examples:
      | swagger version |
      | Swagger 1.2     |
      | Swagger 2       |
      | OAS 3.0         |

  Scenario Outline: Delete the spec
    Given the product has a <swagger version> spec "Echo API"
    When they go to the ActiveDocs page
    And they select action "Delete" of "Echo API"
    And they should see "Yes, I want to delete spec Echo API forever." within the modal
    And press "Delete spec" within the modal
    Then they should see the flash message "ActiveDocs Spec was successfully deleted."
    And they should not see "Echo API"

    Examples:
      | swagger version |
      | Swagger 1.2     |
      | Swagger 2       |
      | OAS 3.0         |
