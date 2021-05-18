@javascript
Feature: Backend API overview page

  Background:
    Given a provider is logged in
    And a backend api "My Backend" using the following products:
      | Product 1 |
      | Product 2 |

  Scenario: Products used by backend table
    When I go to the overview page of backend "My Backend"
    Then I should see the following products being used:
      | Product 1 |
      | Product 2 |

  Scenario: Only accessible products are visible
    Given service "Product 2" becomes inaccessible
    When I go to the overview page of backend "My Backend"
    Then I should not see product "Product 2" being used
