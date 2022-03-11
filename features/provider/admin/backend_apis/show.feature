@javascript
Feature: Backend API overview page

  Background:
    Given a provider is logged in

  Scenario: Products used by backend table
    Given a backend api that is being used by a product
    When an admin is in the backend over page
    Then there is a list of all products using it

  Scenario: Only accessible products are visible
    Given a backend api that is being used by a product
    And the product becomes inaccessible
    When an admin is in the backend over page
    Then the product is not in the list of all products using it
