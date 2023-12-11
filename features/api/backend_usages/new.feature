@javascript
Feature: Product > Integration > Backends > New
  Background:
    Given a provider is logged in

  Rule: There are no backends
    Background:
      Given a product "My API" with no backends
      And they go to the backends of the product

    Scenario: Navigation
      Given they go to the backends of product "My API"
      When they follow "Add a backend"
      Then the current page is the new backend page for product "My API"

    Scenario: Add a backend API
      Given a backend "Backend 1"
      When they go to the new backend page for product "My API"
      And select "Backend 1" from "Backend"
      And fill in "Public Path" with "/v1"
      And press "Add to product"
      Then should see "Backend added to Product."
      And should see the following table:
        | Name      | Public path |
        | Backend 1 | /v1         |

    Scenario: Add a backend API, creating a new one
      Given they go to the new backend page for product "My API"
      When they press "Create a backend"
      And the modal is submitted with:
        | Name             | My new backend         |
        | Private Base URL | http://www.example.com |
      And press "Add to product"
      Then should see "Backend added to Product."
      And should see the following table:
        | Name           | Private base URL          | Public path |
        | My new backend | http://www.example.com:80 | /           |

    Scenario: Can't add the same backend twice
      Given a backend "Backend 1"
      And a backend "Backend 2"
      And backend "Backend 1" is used by product "My API"
      When they go to the new backend page for product "My API"
      Then they can't select "Backend 1" from "Backend"
      But select "Backend 2" from "Backend"

    Scenario: Can't use the same public path twice
      Given the product uses the following backends:
        | Name      | Private endpoint       | path |
        | Backend 1 | http://www.example.com | /v1  |
      And a backend "Other backend"
      When they go to the new backend page for product "My API"
      And select "Other backend" from "Backend"
      And fill in "Public Path" with "/v1"
      And press "Add to product"
      Then they should see "Couldn't add Backend to Product"
      Then "Public Path" shows error "This path is already taken. Specify a different path."

    Scenario: Can't use an invalid public path
      Given a backend "Backend 1"
      When they go to the new backend page for product "My API"
      And select "Backend 1" from "Backend"
      And fill in "Public Path" with "???"
      And press "Add to product"
      Then they should see "Couldn't add Backend to Product"
      And "Public Path" shows error "must be a path separated by \"/\". E.g. \"\" or \"my/path\""

    Scenario: Add a backend must be accessible
      Given a backend "Backend 1"
      But the backend is unavailable
      When they go to the new backend page for product "My API"
      Then they can't select "Backend 1" from "Backend"

  Rule: There are some backends
    Background:
      Given a product "My API"
      And the product uses the following backends:
        | Name      | Private endpoint       | path |
        | Backend 1 | http://www.example.com | /v1  |
        | Backend 2 | http://www.example.com | /v2  |
        | Backend 3 | http://www.example.com | /v3  |

    Scenario: Navigation
      Given they go to the backends of product "My API"
      When they select toolbar action "Add a backend"
      Then the current page is the new backend page for product "My API"
