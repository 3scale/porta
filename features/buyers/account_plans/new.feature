@javascript
Feature: New account plan page

  Background:
    Given a provider is logged in
    And the provider has "account_plans" allowed

  Scenario: Navigation
    Given they go to the account plans admin page
    When they select toolbar action "Create account plan"
    Then the current page is the new account plan admin page

  Scenario: Create an account plan
    Given they go to the new account plan admin page
    When the form is submitted with:
      | Name        | Premium |
      | System name | premium |
    Then the current page is the account plans admin page
    And they should see "Created account plan Premium"
    And the table has the following row:
      | Name    | Contracts | State  |
      | Premium | 0         | hidden |

  Scenario: System name is optional
    Given they go to the new account plan admin page
    When the form is submitted with:
      | Name        | Premium |
      | System name |         |
    And they should see "Created account plan Premium"

  @wip
  Scenario: Create a account plan with billing enabled
  # TODO: Given billing is enabled. See app/views/api/plans/forms/_billing_strategy.html.erb

  Scenario: Form validation
    Given they go to the new account plan admin page
    When the form is submitted with:
      | Name        |  |
      | System name |  |
    Then field "Name" has inline error "Can't be blank"


