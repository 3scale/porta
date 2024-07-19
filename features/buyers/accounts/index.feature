@javascript
Feature: Audience > Accounts

  Background:
    Given a provider is logged in

  Scenario: Empty state
    Given the provider has no buyers
    When they go to the buyer accounts page
    Then they should see an empty state
    And should see "Add your first account"

  Scenario: Provider has one account plan only
    Given a buyer "Alice" of the provider
    When they go to the buyer accounts page
    Then the table does not have a column "Plan"

  Scenario: Provider has multiple applications disabled
    Given a buyer "Pepe" of the provider
    And the default product of the provider has name "The API"
    And the following application plan:
      | Product | Name | Default |
      | The API | Free | true    |
    And the provider has multiple applications disabled
    When they go to the buyer accounts page
    Then the table don't have a column "Apps"

  Scenario: Provider has multiple applications enabled
    Given a buyer "Pepe" of the provider
    And the default product of the provider has name "The API"
    And the following application plan:
      | Product | Name | Default |
      | The API | Free | true    |
    And the provider has multiple applications enabled
    When they go to the buyer accounts page
    Then should see following table:
      | Group/Org. | Apps |
      | Pepe       | 0    |

  Rule: Provider has many account plans
    Background:
      Given the provider has the following buyers:
        | Name          | State    | Plan    |
        | Alice         | approved | Default |
        | Bob           | rejected | Awesome |
        | Pending buyer | pending  | Tricky  |

    Scenario: The account plan is in the table
      Given they go to the buyer accounts page
      Then the table has a column "Plan"

    Scenario: Pagination
      Given the provider has 12 buyers
      When they go to the buyer accounts page with 10 records per page
      Then the table should have 10 rows
      But they look at the 2nd page
      And the table should have 2 rows

    Scenario: Ordering by group/org
      Given they go to the buyer accounts page
      When follow "Group/Org." within the table header
      Then should see following table:
        | Group/Org.    | State    | Plan    |
        | Alice         | Approved | Default |
        | Bob           | Rejected | Awesome |
        | Pending buyer | Pending  | Tricky  |
      And follow "Group/Org." within the table header
      Then should see following table:
        | Group/Org.    | State    | Plan    |
        | Pending buyer | Pending  | Tricky  |
        | Bob           | Rejected | Awesome |
        | Alice         | Approved | Default |

    Scenario: Ordering by plan name
      Given they go to the buyer accounts page
      When follow "Plan" within the table header
      Then should see following table:
        | Group/Org.    | State    | Plan    |
        | Bob           | Rejected | Awesome |
        | Alice         | Approved | Default |
        | Pending buyer | Pending  | Tricky  |
      And follow "Plan" within the table header
      And should see following table:
        | Group/Org.    | State    | Plan    |
        | Pending buyer | Pending  | Tricky  |
        | Alice         | Approved | Default |
        | Bob           | Rejected | Awesome |

    Scenario: Ordering by state
      Given they go to the buyer accounts page
      When follow "State" within the table header
      Then should see following table:
        | Group/Org.    | State    | Plan    |
        | Alice         | Approved | Default |
        | Pending buyer | Pending  | Tricky  |
        | Bob           | Rejected | Awesome |
      And follow "State" within the table header
      And should see following table:
        | Group/Org.    | State    | Plan    |
        | Bob           | Rejected | Awesome |
        | Pending buyer | Pending  | Tricky  |
        | Alice         | Approved | Default |

    Scenario: Ordering by signup date
      Given they go to the buyer accounts page
      When follow "Signup Date" within the table header
      Then should see following table:
        | Group/Org.    | State    | Plan    |
        | Pending buyer | Pending  | Tricky  |
        | Bob           | Rejected | Awesome |
        | Alice         | Approved | Default |
      And follow "Signup Date" within the table header
      And should see following table:
        | Group/Org.    | State    | Plan    |
        | Alice         | Approved | Default |
        | Bob           | Rejected | Awesome |
        | Pending buyer | Pending  | Tricky  |

    Scenario: Current user can export accounts to CSV
      Given the current user can export data
      When they go to the buyer accounts page
      Then they select toolbar action "Export to CSV"
      And the current page is the admin portal data exports page

    Scenario: Current user cannot export accounts to CSV
      Given the current user can't export data
      When they go to the buyer accounts page
      Then they can't find toolbar action "Export to CSV"

    Scenario: Deleted accounts are not listed
      Given account "Bob" is deleted
      When they go to the buyer accounts page
      Then they should not see "Bob" in the buyer accounts table

    @wip
    Scenario: Can't create an account without permission
      Given the buyer can't create more accounts
      When they go to the buyer accounts page
      Then they can't find toolbar action "Add an account"
      Given the buyer can create more accounts
      When they go to the buyer accounts page
      Then they can find toolbar action "Add an account"

    @search
    Scenario: Filtering by multiple criteria
      Given they go to the buyer accounts page
      When the table is filtered with:
        | filter | value   |
        | State  | Pending |
        | Plan   | Tricky  |
      And they search "pending" using the toolbar
      Then they should see the following table:
        | Group/Org.    | State   | Plan   |
        | Pending buyer | Pending | Tricky |

    @search
    Scenario: Search returns no results
      Given they go to the buyer accounts page
      When they search and there are no results
      Then they should see an empty search state
      And they should be able to reset the search

    @search
    Scenario: Filtering by plan
      Given they go to the buyer accounts page
      And the table is filtered with:
        | filter | value   |
        | Plan   | Default |
      Then they should see the following table:
        | Group/Org. | State    | Plan    |
        | Alice      | Approved | Default |
      And can reset the toolbar filter "plan"

    @search
    Scenario: Filtering by state
      Given they go to the buyer accounts page
      When the table is filtered with:
        | filter | value   |
        | State  | Pending |
      Then they should see the following table:
        | Group/Org.    | State   | Plan   |
        | Pending buyer | Pending | Tricky |
      When the table is filtered with:
        | filter | value    |
        | State  | Approved |
      Then they should see following table:
        | Group/Org. | State    | Plan    |
        | Alice      | Approved | Default |
      And can reset the toolbar filter "state"

    @search
    Scenario: Filtering by org name
      Given they go to the buyer accounts page
      When they search "ali" using the toolbar
      Then they should see following table:
        | Group/Org. | State    | Plan    |
        | Alice      | Approved | Default |
      And the search input should be filled with "ali"
      When they search "alice" using the toolbar
      Then they should see following table:
        | Group/Org. | State    | Plan    |
        | Alice      | Approved | Default |
      And the search input should be filled with "alice"

    @search
    Scenario: Filtering by user's name
      Given an user of account "Bob" with first name "Eric" and last name "Cartman"
      When they go to the buyer accounts page
      And they search "eric" using the toolbar
      Then they should see following table:
        | Group/Org. | State    | Plan    |
        | Bob        | Rejected | Awesome |

    @search
    Scenario: Filtering by user's username
      Given an user "Banana" of account "Bob"
      When they go to the buyer accounts page
      And they search "banana" using the toolbar
      Then they should see following table:
        | Group/Org. | State    | Plan    |
        | Bob        | Rejected | Awesome |

    @search
    Scenario: Recently created account is searchable
      Given a recently creater buyer account "Bob's Web Widgets"
      And they go to the buyer accounts page
      And they search "widgets" using the toolbar
      Then they should see following table:
        | Group/Org.        |
        | Bob's Web Widgets |

    @search
    Scenario: Special characters does not make sphinx crash
      When they go to the buyer accounts page
      And they search "$bob" using the toolbar
      Then they should see following table:
        | Group/Org. | State    | Plan    |
        | Bob        | Rejected | Awesome |
      But they search "b$ob" using the toolbar
      Then they should see an empty search state

    @security
    Scenario: Buyers from other providers are not listed
      Given a provider "bar.3scale.localhost"
      And provider "bar.3scale.localhost" has multiple applications enabled
      And a buyer "claire" signed up to provider "bar.3scale.localhost"
      When they go to the buyer accounts page
      Then they should not see "claire" in the buyer accounts table

    @allow-rescue
    Scenario: Search server is down
      Given the search server is offline
      When they go to the buyer accounts page
      And they search "bananas" using the toolbar
      Then should see "Search is temporarily offline. Please try again in few minutes."
