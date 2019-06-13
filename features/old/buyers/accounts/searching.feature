@search @no-txn
Feature: Searching buyer accounts
  In order to find a buyer account I'm looking for
  As a provider
  I want to have a full-text search at my disposal

  Background:
    Given a provider "foo.example.com"
    Given a default account plan "Default" of provider "foo.example.com"
    And a account plan "Awesome" of provider "foo.example.com"
    And a account plan "Tricky" of provider "foo.example.com"
    Given I have following countries:
      | Code | Name           |
      | IT   | Italy          |
      | UK   | United Kingdom |
    And provider "foo.example.com" has multiple applications enabled
    And provider "foo.example.com" has the following buyers:
      | Name          | State    | Plan    | Country |
      | alice         | approved | Default |         |
      | bob           | approved | Awesome | United Kingdom |
      | bad buyer     | rejected | Default |         |
      | pending buyer | pending  | Tricky  | Italy   |
    And the Sphinx indexes are updated

     And current domain is the admin domain of provider "foo.example.com"
     When I log in as provider "foo.example.com"


  Scenario: Search
    When I go to the buyer accounts page
    When I search for:
      | Group/Org. | State   | Plan   |
      | pending    | Pending | Tricky |
    Then I should see following table:
      | Group/Org.    | State   | Plan   |
      | pending buyer | Pending | Tricky |

  Scenario: Listing
    When I go to the buyer accounts page with 1 records per page
    Then I should see 4 pages
    When I search for:
      | Plan    |
      | Default |
    Then I should see 2 pages
    And I follow "Group/Org." within table header
    And I should see following table:
      | Group/Org. ▲ |
      | alice        |
    When I look at 2nd page
    Then I should see following table:
      | Group/Org. ▲ |
      | bad buyer    |
    And I should see 2 pages

  Scenario Outline: Ordering
    When I go to the buyer accounts page
    When I search for:
      | Plan    | State    | Group/Org. | Country |
      | Awesome | Approved | bob        | Italy   |
    And I follow "<order by>" within table header
    Then I should see "<order by> ▲"

    Examples:
      | order by    |
      | Plan        |
      | State       |
      | Group/Org.  |
      | Signup Date |

  Scenario: All buyer accounts show as defaults
    When I go to the buyer accounts page
    And I should see "alice" and "bob" in the buyer accounts table
    And I should see "bad buyer" and "pending buyer" in the buyer accounts table

  Scenario: Listing pending and rejected buyer accounts
    When I go to the buyer accounts page
    When I search for:
      | State   |
      | Pending |
    And I follow "Group/Org." within table header
    Then I should see following table:
      | Group/Org. ▲  |
      | pending buyer |

    When I search for:
      | State    |
      | Approved |
    Then I should see following table:
      | Group/Org. ▲ |
      | alice        |
      | bob          |

  Scenario: Listing all buyer accounts
    When I go to the buyer accounts page
    And I follow "Group/Org." within table header
    Then I should see following table:
      | Group/Org. ▲  | State    |
      | alice         | Approved |
      | bad buyer     | Rejected |
      | bob           | Approved |
      | pending buyer | Pending  |

  Scenario: Search account by name
    When I go to the buyer accounts page
    When I search for:
      | Group/Org. |
      | alice      |
    Then I should see following table:
      | Group/Org. |
      | alice      |

  Scenario: Search account by name substring
    When I go to the buyer accounts page
    When I search for:
      | Group/Org. |
      | ali        |
    Then I should see following table:
      | Group/Org. |
      | alice      |

  Scenario: Search by user's name
    Given an user of account "bob" with first name "Eric" and last name "Cartman"
    And the Sphinx indexes are updated

    When I go to the buyer accounts page
    And I search for:
      | Group/Org. |
      | eric       |
    Then I should see following table:
      | Group/Org. |
      | bob        |

    When I search for:
      | Group/Org. |
      | eric       |
    Then I should see following table:
      | Group/Org. |
      | bob        |

  Scenario: Search by user's username
    Given an user "awesomo" of account "bob"
    And the Sphinx indexes are updated

    When I go to the buyer accounts page
    When I search for:
      | Group/Org. |
      | awesomo    |
    Then I should see following table:
      | Group/Org. |
      | bob        |

  # TODO: Search by user email, account address, applications name and description, telephone number, ...

  Scenario: Recently created account is searchable
    When I create new buyer account "Bob's Web Widgets"
     And the Sphinx indexes are updated

    And I go to the buyer accounts page
    And I search for:
      | Group/Org. |
      | widgets    |
    Then I should see following table:
      | Group/Org.        |
      | Bob's Web Widgets |

  @security
  Scenario: Does not list buyers of other providers
    Given a provider "bar.example.com"
    And provider "bar.example.com" has multiple applications enabled
    And a buyer "claire" signed up to provider "bar.example.com"

    When I go to the buyer accounts page
    Then I should not see "claire" in the buyer accounts table

  Scenario: Does not list deleted accounts
    Given account "bob" is deleted
    And the Sphinx indexes are updated

    When I go to the buyer accounts page
    Then I should not see "bob" in the buyer accounts table

  Scenario: Should not crash on sphinx special characters
    When I go to the buyer accounts page
    And I search for:
      | Group/Org. |
      | $bob       |
   Then I should see 1 buyers in the buyer accounts table

  Scenario: Lists 10 accounts per page
    Given provider "foo.example.com" has 12 buyers
    And the Sphinx indexes are updated

    When I go to the buyer accounts page with 10 records per page
    Then I should see only 10 buyers in the buyer accounts table

    When I follow "Next"
    Then I should see 2 buyers in the buyer accounts table

  @allow-rescue
  Scenario: Friendly error message when search server is down
    Given Sphinx is offline
    When I go to the buyer accounts page
    And I search for:
      | Group/Org. |
      | gorillas   |
    Then I should see "Search is temporarily offline. Please try again in few minutes."

