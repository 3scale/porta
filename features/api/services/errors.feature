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
    Then they should see "Hooray! No integration errors reported for this service."

  Scenario: List of errors
    Given the product has the following integration errors:
      | Timestamp | Message |
      | 3/3/1991  | Error 1 |
      | 4/4/1992  | Error 2 |
    When they go to the integration errors page of product "Pepe API"
    Then they should see the following table:
      | Time (UTC)                | Error   |
      | 1991-03-03 00:00:00 +0100 | Error 1 |
      | 1992-04-04 00:00:00 +0200 | Error 2 |

  Scenario: Empty list
    Given the product has the following integration errors:
      | Timestamp | Message |
      | 3/3/1991  | Error 1 |
      | 4/4/1992  | Error 2 |
    When they go to the integration errors page of product "Pepe API"
    And press "Purge"
    And wait a moment
    # TODO: Since ThreeScale::Core::ServiceError is mocked, errors are not really deleted.
    # Then they should see "Hooray! No integration errors reported for this service."
