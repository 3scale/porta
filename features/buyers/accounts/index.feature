@javascript
Feature: Accounts Listing

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

    Scenario: Bulk operations does not include Change account plan
      Given the provider has "account_plans" switch allowed
      And they go to the buyer accounts page
      When item "Alice" is selected
      Then the following bulk operations are available:
        | Send email   |
        | Change state |

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

    Scenario: Bulk operations when Account Plans are disabled
      Given the provider has "account_plans" switch denied
      And they go to the buyer accounts page
      When item "Alice" is selected
      Then the following bulk operations are available:
        | Send email   |
        | Change state |

    Scenario: Bulk operations when Account Plans are enabled
      Given the provider has "account_plans" switch allowed
      And they go to the buyer accounts page
      When item "Alice" is selected
      Then the following bulk operations are available:
        | Send email          |
        | Change account plan |
        | Change state        |

    Scenario: Bulk operations card shows when an items are selected
      Given they go to the buyer accounts page
      When item "Alice" is selected
      And item "Bob" is selected
      Then the bulk operations are visible
      And should see "You have selected 2 accounts and you can make following operations with them:"
      But item "Alice" is unselected
      And item "Bob" is unselected
      Then the bulk operations are not visible

    Scenario: Select all items in the table
      Given they go to the buyer accounts page
      And they select all items in the table
      Then the bulk operations are visible
      When they unselect all items in the table
      Then the bulk operations are not visible
