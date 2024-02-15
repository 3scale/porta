@javascript
Feature: Product > Integration > Backends > Edit
  Background:
    Given a provider is logged in
    And a product "My API"
    And the product uses the following backends:
      | Name      | Private endpoint       | path |
      | Backend 1 | http://www.example.com | /v1  |

  Scenario: Navigation
    Given the current page is the provider dashboard
    When they select "Products" from the context selector
    And follow "My API"
    And press "Integration" within the main menu
    And follow "Backends" within the main menu
    And follow "Edit config with Backend 1" to the edit backend usage page of "Backend 1" for product "My API"
    Then the current page is the edit backend usage page of "Backend 1" for product "My API"

  Scenario: Changing the public path
    Given they go to the edit backend usage page of "Backend 1" for product "My API"
    When the form is submitted with:
      | Public Path | /banana |
    Then they should see "Backend usage was updated."
    And should see the following table:
      | Name      | Public path |
      | Backend 1 | /banana     |

  Scenario: Can't use an invalid path
    Given they go to the edit backend usage page of "Backend 1" for product "My API"
    When the form is submitted with:
      | Public Path | ??? |
    Then field "Path" has inline error "must be a path separated by \"/\". E.g. \"\" or \"my/path\""

  Scenario: Can't use the same public path twice
    Given the product uses the following backends:
      | Name      | Private endpoint       | path |
      | Backend 2 | http://www.example.com | /v2  |
    Given they go to the edit backend usage page of "Backend 1" for product "My API"
    When the form is submitted with:
      | Public Path | /v2 |
    Then field "Path" has inline error "This path is already taken. Specify a different path."

  Scenario: User changes their mind
    Given they go to the edit backend usage page of "Backend 1" for product "My API"
    When they follow "Cancel"
    Then the current page is the backends of the product
