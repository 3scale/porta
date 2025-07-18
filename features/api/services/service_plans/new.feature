@javascript
Feature: Product's new service plan page

  Background:
    Given a provider is logged in
    And the provider has "service_plans" allowed
    And a product "My API"
    And they go to the product's new service plan admin page

  Scenario: Navigation
    Given they go to product "My API" service plans admin page
    When they select toolbar action "Create service plan"
    Then the current page is the product's new service plan admin page

  Scenario: Create an service plan
    Given they go to the product's new service plan admin page
    When the form is submitted with:
      | Name        | Premium |
      | System name | premium |
    Then the current page is the product's service plans admin page
    And they should see "Created service plan Premium"
    And the table has the following row:
      | Name    | Contracts | State  |
      | Premium | 0         | hidden |

  Scenario: System name is optional
    Given they go to the product's new service plan admin page
    When the form is submitted with:
      | Name        | Premium |
      | System name |         |
    And they should see "Created service plan Premium"

  @wip
  Scenario: Create a service plan with billing enabled
    # TODO: Given billing is enabled. See app/views/api/plans/forms/_billing_strategy.html.erb

  Scenario: Form validation
    Given they go to the product's new service plan admin page
    When the form is submitted with:
      | Name        | |
      | System name | |
    Then field "Name" has inline error "Can't be blank"
