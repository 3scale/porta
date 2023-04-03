Feature: Product > Overview page
  Background:
    Given a provider is logged in with a product "My Product"
    And it uses the following backends:
      | Name      | path |
      | Backend 3 | /v3  |
      | Backend 2 | /v2  |
      | Backend 1 | /v1  |

  @javascript
  Scenario: List of backends used is ordered alphabetically
    When I go to the overview page of product "My Product"
    Then I should see the following backends being used:
      | Backend 1 |
      | Backend 2 |
      | Backend 3 |
