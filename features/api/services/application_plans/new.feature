@javascript
Feature: Product's new application plans page

  Background:
    Given a provider is logged in
    And a product

  Scenario: Navigation
    Given they go to the product's application plans admin page
    When they select toolbar action "Create application plan"
    Then the current page is the product's new application plan admin page

  @onpremises
  Scenario: Create an application plan when onpremises
    Given they go to the product's new application plan admin page
    When the form is submitted with:
      | Name        | Premium |
      | System name | premium |
    Then the current page is the product's application plans admin page
    And they should see "Created application plan Premium"
    And the table has the following row:
      | Name    | Contracts | State  |
      | Premium | 0         | hidden |

  Scenario: Create an application plan
    Given they go to the product's new application plan admin page
    When the form is submitted with:
      | Name        | Premium |
      | System name | premium |
    Then the current page is the product's application plans admin page
    And they should see "Created application plan Premium"
    And the table has the following row:
      | Name    | Contracts | State  |
      | Premium | 0         | hidden |

  Scenario: System name is optional
    Given they go to the product's new application plan admin page
    When the form is submitted with:
      | Name        | Premium |
      | System name |         |
    And they should see "Created application plan Premium"

  @wip
  Scenario: Create an application plan with billing enabled
    # TODO: Given billing is enabled. See app/views/api/plans/forms/_billing_strategy.html.erb

  Scenario: Form validation
    Given they go to the product's new application plan admin page
    When the form is submitted with:
      | Name        | |
      | System name | |
    Then field "Name" has inline error "Can't be blank"
