@javascript
Feature: Buyer accounts index

  Background:
    Given a provider is logged in

  Rule: Provider has no buyers
    Scenario: Empty state
      Given they go to the buyer accounts page
      # FIXME: it should be different than the search empty state
      Then they should see an empty state

  Rule: Provider has a single account plan
    Background:
      Given a buyer "Alice" of the provider

    Scenario: The account plan is not in the table
      Given they go to the buyer accounts page
      Then the table does not have a column "Plan"

  Rule: Provider has many account plans
    Background:
      Given the provider has the following buyers:
        | Name          | State    | Plan    |
        | Alice         | approved | Default |
        | Bob           | approved | Awesome |
        | Bad buyer     | rejected | Default |
        | Pending buyer | pending  | Tricky  |

    Scenario: The account plan is in the table
      Given they go to the buyer accounts page
      Then the table has a column "Plan"

    @search
    Scenario: Search for an account
      Given they go to the buyer accounts page
      When they search for:
        | Group/Org. | State   | Plan   |
        | pending    | Pending | Tricky |
      Then they should see the following table:
        | Group/Org.    | State   | Plan   |
        | Pending buyer | Pending | Tricky |

    @search
    Scenario: Search returns no results
      Given they go to the buyer accounts page
      When they search and there are no results
      Then they should see an empty state
      And they should be able to reset the search
