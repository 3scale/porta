@javascript
Feature: Integration errors of a product

  As an admin I want to see the list of integration errors of a product
  and I want to be able to empty such list

  Background:
    Given a provider is logged in
    And a product "Pepe API"

  Scenario: Navigation
    Given they go to the overview page of product "Pepe API"
    When they press "Analytics" within the main menu
    And follow "Integration Errors" within the main menu
    Then the current page is the integration errors page of product "Pepe API"

  Scenario: No errors
    Given they go to the integration errors page of product "Pepe API"
    Then they should see "No integration errors reported for this service"

  Rule: There are errors
    Background:
      Given the product has the following integration errors:
        | Timestamp               | Message |
        | 2024-03-03 12:00:00 UTC | Error 1 |
        | 2024-01-01 13:00:00 UTC | Error 2 |

    Scenario: List of errors
      When they go to the integration errors page of product "Pepe API"
      Then they should see the following table:
        | Time (UTC)              | Error   |
        | 2024-03-03 12:00:00 UTC | Error 1 |
        | 2024-01-01 13:00:00 UTC | Error 2 |

    Scenario: Empty the table
      Given they want to empty the integration errors table
      And they go to the integration errors page of product "Pepe API"
      And they should see the following table:
        | Time (UTC)              | Error   |
        | 2024-03-03 12:00:00 UTC | Error 1 |
        | 2024-01-01 13:00:00 UTC | Error 2 |
      When they select toolbar action "Purge"
      And confirm the dialog
      Then they should see a toast alert with text "All errors were purged"
      And they should see "No integration errors reported for this service"
