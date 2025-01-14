@javascript
Feature: Product > Integration > Backends
  Background:
    Given a provider is logged in

  Rule: no backends
    Background:
      Given a product "My API" with no backends
      And they go to the backends of the product

    Scenario: Empty state
      Then they should see "There are no backends yet"
      And should see "Add a backend"

  Rule: some backends
    Background:
      Given a product "My API"
      And the product uses the following backends:
        | Name      | Private endpoint       | path |
        | Backend 1 | http://www.example.com | /v1  |
        | Backend 2 | http://www.example.com | /v2  |
        | Backend 3 | http://www.example.com | /v3  |

    Scenario: Navigation from Products
      Given the current page is the provider dashboard
      When they select "Products" from the context selector
      And follow "My API"
      And press "Integration" within the main menu
      And follow "Backends" within the main menu
      Then the current page is the backends of product "My API"

    Scenario: Navigation from Dashboard
      Given they go to the provider dashboard
      When they follow "My API" within the products widget
      And press "Integration" within the main menu
      And follow "Backends" within the main menu
      Then the current page is the backends of product "My API"

    Scenario: Backends table
      When they go to the backends of product "My API"
      Then they should see the following table:
        | Name      | Private base URL          | Public path |
        | Backend 1 | http://www.example.com:80 | /v1         |
        | Backend 2 | http://www.example.com:80 | /v2         |
        | Backend 3 | http://www.example.com:80 | /v3         |

    Scenario: Deleting a backend config
      When they go to the backends of product "My API"
      And follow "Delete config with Backend 1"
      And confirm the dialog
      Then they should see the flash message "The Backend was removed from the Product"
      And should see the following table:
        | Name      | Private base URL          | Public path |
        | Backend 2 | http://www.example.com:80 | /v2         |
        | Backend 3 | http://www.example.com:80 | /v3         |
