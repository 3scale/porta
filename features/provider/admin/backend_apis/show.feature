@javascript
Feature: Backend API overview page

  Background:
    Given a provider is logged in

  Scenario: Vertical navigation structure
    Given a backend "Backend API"
    When an admin is in the backend overview page
    Then they should see "Backend API" within the main menu
    And the sidebar should have the following sections:
      | Backend Overview            |
      | Analytics           |
      | Methods and Metrics |
      | Mapping Rules       |

  Scenario: Products used by backend table
    Given a product
    And a backend
    And the backend is used by the product
    When an admin is in the backend overview page
    Then there is a list of all products using it

  Scenario: Only accessible products are visible
    Given a product
    And a backend
    And the backend is used by the product
    And the product becomes inaccessible
    When an admin is in the backend overview page
    Then the product is not in the list of all products using it
