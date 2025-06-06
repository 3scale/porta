@javascript
Feature: Product ActiveDocs page

  As a provider, I want to manage my ActiveDocs

  Background:
    Given a provider
    And a product "My API"
    And the provider logs in

  Scenario: Navigation from the dashboard
    When they select action "ActiveDocs" of "My API" within the products widget
    Then the current page is the product's ActiveDocs page

  Scenario: Navigation from context
    When they select "Products" from the context selector
    And follow "My API"
    And follow "ActiveDocs" within the main menu
    Then the current page is the product's ActiveDocs page

  Scenario: Empty view
    Given the product has no specs
    When they go to the product's ActiveDocs page
    Then they should not see "There are unattached ActiveDocs"
    Then there should be a link to "Create your first spec"

  Scenario Outline: There are unattached ActiveDocs
    Given the provider has a <swagger version> spec "Echo API"
    When they go to the product's ActiveDocs page
    Then they should see "There are unattached ActiveDocs"
    And there should be a link to "1 or more ActiveDocs"
    And there should be a link to "Create your first spec"

    Examples:
      | swagger version |
      | Swagger 1.2     |
      | Swagger 2       |
      | OAS 3.0         |
  @wip
  Scenario: Index does not show the API column
    Given the product has a Swagger 2 spec "Echo API"
    When they go to the product's ActiveDocs page
    Then there should not be a link to "Create your first spec"
    Then the table should not have a column "API"
  @wip
  Scenario Outline: Hide the spec
    Given the product has a <swagger version> spec "Echo API"
    And the spec is published
    When they go to the product's ActiveDocs page
    And they select action "Hide" of "Echo API"
    Then they should see a toast alert with text "Spec Echo API is now hidden"
    And the table has the following row:
      | Name     | State  |
      | Echo API | hidden |

    Examples:
      | swagger version |
      | Swagger 1.2     |
      | Swagger 2       |
      | OAS 3.0         |
  @wip
  Scenario Outline: Publish the spec
    Given the product has a <swagger version> spec "Echo API"
    And the spec is not published
    When they go to the product's ActiveDocs page
    And they select action "Publish" of "Echo API"
    Then they should see a toast alert with text "Spec Echo API is now visible"
    And the table has the following row:
      | Name     | State   |
      | Echo API | visible |

    Examples:
      | swagger version |
      | Swagger 1.2     |
      | Swagger 2       |
      | OAS 3.0         |
  @wip
  Scenario Outline: Delete the spec
    Given the product has a <swagger version> spec "Echo API"
    When they go to the product's ActiveDocs page
    And they select action "Delete" of "Echo API"
    And they should see "Yes, I want to delete spec Echo API forever" within the modal
    And press "Delete spec" within the modal
    Then they should see a toast alert with text "ActiveDocs Spec was successfully deleted"
    And they should not see "Echo API"

    Examples:
      | swagger version |
      | Swagger 1.2     |
      | Swagger 2       |
      | OAS 3.0         |
