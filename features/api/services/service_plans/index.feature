@javascript
Feature: Product's service plans index page

  In order to manage service plans from the index page, I want to perform the following
  actions: create, copy, edit, delete, publish and hide. Moreover, I want to sort the table
  by name, no. of apps and state.

  Background:
    Given a provider is logged in
    And the provider has "service_plans" allowed
    And a product "My API" with no service plans

  Scenario: Navigation via main menu
    Given they go to the provider dashboard
    When they follow "My API" within the products widget
    And press "Subscriptions" within the main menu
    And follow "Service Plans" within the main menu
    Then the current page is the product's service plans admin page

  Rule: Managing plans
    Background:
      Given the following service plan:
        | Product | Name        | State     |
        | My API  | Public Plan | Published |
        | My API  | Secret Plan | Hidden    |
      And they go to product "My API" service plans admin page

    Scenario: Copying service plans
      When they select action "Copy" of "Public Plan"
      And they select action "Copy" of "Secret Plan"
      And wait a moment
      Then they should see "Plan copied"
      And the table has the following row:
        | Name               | Contracts | State     |
        | Public Plan (copy) | 0         | published |
        | Secret Plan (copy) | 0         | hidden    |

    Scenario: Deleting service plans
      Given service plan "Public Plan" has 0 contracts
      And they go to the product's service plans admin page
      When they select action "Delete" of "Public Plan"
      And confirm the dialog
      And wait a moment
      Then they should see "Plan was deleted"
      And the table should contain the following:
        | Name        | Contracts | State  |
        | Secret Plan | 0         | hidden |

    Scenario: Plans in use can't be deleted
      Given service plan "Public Plan" has 1 contract
      And they go to the product's service plans admin page
      Then the actions of row "Public Plan" are:
        | Hide |
        | Copy |

    Scenario: Service plans are scoped by service
      Given a product "Other API" with no service plans
      And the following service plans:
        | Product   | Name        |
        | Other API | Normal Plan |
        | Other API | Super Plan  |
      And they go to product "Other API" service plans admin page
      Then the table should contain the following:
        | Name        |
        | Normal Plan |
        | Super Plan  |

    Scenario: Hiding service plans
      When they select action "Hide" of "Public Plan"
      And wait a moment
      Then they should see "Plan Public Plan was hidden"
      And the table has the following row:
        | Name        | State  |
        | Public Plan | hidden |
      And the actions of row "Public Plan" are:
        | Publish |
        | Copy    |
        | Delete  |

    Scenario: Publishing service plans
      When they select action "Publish" of "Secret Plan"
      And wait a moment
      Then they should see "Plan Secret Plan was published"
      And the table has the following row:
        | Name        | State     |
        | Secret Plan | published |
      And the actions of row "Secret Plan" are:
        | Hide   |
        | Copy   |
        | Delete |

  Rule: Filtering
    Background:
      Given the following service plans:
        | Product | Name                        | State     |
        | My API  | This is number One          | Hidden    |
        | My API  | Now the second one          | Hidden    |
        | My API  | Finally the last            | Published |
        | My API  | This has been bought        | Published |
        | My API  | This has been bought twice! | Published |
      And they go to product "My API" service plans admin page

    @search
    Scenario: Filtering service plans
      When they search "one" using the toolbar
      Then the table should contain the following:
        | Name               |
        | This is number One |
        | Now the second one |
      When they search "last" using the toolbar
      Then the table should contain the following:
        | Name             |
        | Finally the last |
      When they search "foooo" using the toolbar
      Then the table should contain the following:
        | Name |

  Rule: Sorting
    Background:
      And the following service plans:
        | Product | Name | State     |
        | My API  | AAA  | Hidden    |
        | My API  | BBB  | Published |
        | My API  | CCC  | Published |
      And they go to product "My API" service plans admin page

    Scenario: Sorting service plans by name
      When the table is sorted by "Name"
      Then the table should contain the following:
        | Name |
        | AAA  |
        | BBB  |
        | CCC  |
      When the table is sorted by "Name" again
      Then the table should contain the following:
        | Name |
        | CCC  |
        | BBB  |
        | AAA  |

    Scenario: Sorting service plans by contracts
      Given service plan "BBB" has 2 contracts
      And service plan "CCC" has 1 contract
      When the table is sorted by "Contract"
      Then the table should contain the following:
        | Name |
        | BBB  |
        | CCC  |
        | AAA  |
      When the table is sorted by "Contract" again
      Then the table should contain the following:
        | Name |
        | AAA  |
        | CCC  |
        | BBB  |

    Scenario: Sorting service plans by state
      Given service plan "AAA" is hidden
      And service plan "CCC" is hidden
      When the table is sorted by "State"
      Then the table should contain the following:
        | Name |
        | BBB  |
        | AAA  |
        | CCC  |
      When the table is sorted by "State" again
      Then the table should contain the following:
        | Name |
        | AAA  |
        | CCC  |
        | BBB  |

  Rule: Service plans are disabled

    Background:
      Given the provider has "service_plans" denied

    Scenario: Service plans are hidden
      Given they go to the provider dashboard
      When they follow "My API" within the products widget
      Then they should not see "Subscriptions" within the main menu
