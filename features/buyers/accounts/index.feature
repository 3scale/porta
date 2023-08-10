@search @javascript
Feature: Accounts Listing

  Background:
    Given a provider is logged in
    And the provider has the following buyers:
      | Name          | State    | Plan    |
      | Alice         | approved | Default |
      | Bob           | approved | Awesome |
      | Bad buyer     | rejected | Default |
      | Pending buyer | pending  | Tricky  |

  Scenario: Search for an account
    Given they go to the buyer accounts page
    When they search for:
      | Group/Org. | State   | Plan   |
      | pending    | Pending | Tricky |
    Then they should see the following table:
      | Group/Org.    | State   | Plan   |
      | Pending buyer | Pending | Tricky |

  Scenario: Search returns no results
    Given they go to the buyer accounts page
    When they search and there are no results
    Then they should see an empty state
    And they should be able to reset the search
