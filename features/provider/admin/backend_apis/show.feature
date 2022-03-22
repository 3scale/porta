@javascript
Feature: Backend API overview page

  Background:
    Given a provider is logged in

  Scenario: Vertical navigation structure
    Given a backend
    When an admin is in the backend overview page
    Then the name of the backend can be seen on top of the menu
    And I should see menu items
    | Overview                    |
    | Methods and Metrics         |
    | Mapping Rules               |

  Scenario: Products used by backend table
    Given a product
    And a backend used by this product
    When an admin is in the backend overview page
    Then there is a list of all products using it

  Scenario: Only accessible products are visible
    Given a product
    And a backend used by this product
    And the product becomes inaccessible
    When an admin is in the backend overview page
    Then the product is not in the list of all products using it
