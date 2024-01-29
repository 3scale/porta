@javascript
Feature: Product's application plans index page

  In order to manage application plans from the index page, I want to perform the following
  actions: create, copy, edit, delete, publish and hide. Moreover, I want to sort the table
  by name, no. of apps and state.

  Background:
    Given a provider is logged in
    And a product "My API"

  Scenario: Navigation via main menu
    Given they go to the provider dashboard
    When they follow "My API" within the products widget
    And press "Applications" within the main menu
    And follow "Application Plans" within the main menu
    Then the current page is the product's application plans admin page

  Scenario: Navigation via products widget
    Given they go to the provider dashboard
    When they select action "Applications" of "My API" within the products widget
    And follow "Application Plans" within the main menu
    Then the current page is the product's application plans admin page

  Rule: Managing plans
    Background:
      And the following application plans:
        | Product | Name        | State     |
        | My API  | Public Plan | Published |
        | My API  | Secret Plan | Hidden    |
      And they go to the product's application plans admin page

    Scenario: Copying application plans
      When they select action "Copy" of "Public Plan"
      And they select action "Copy" of "Secret Plan"
      Then they should see "Plan copied"
      And the table has the following row:
        | Name               | Contracts | State     |
        | Public Plan (copy) | 0         | published |
        | Secret Plan (copy) | 0         | hidden    |

    Scenario: Deleting application plans
      Given application plan "Public Plan" has 0 contracts
      And they go to the product's application plans admin page
      When they select action "Delete" of "Public Plan"
      And confirm the dialog
      Then they should see "Plan was deleted"
      And the table looks like:
        | Name        | Contracts | State  |
        | Secret Plan | 0         | hidden |

    Scenario: Plans in use can't be deleted
      Given application plan "Public Plan" has 1 contract
      And they go to the product's application plans admin page
      Then the actions of row "Public Plan" are:
        | Hide |
        | Copy |

    Scenario: Application plans are scoped by service
      Given a product "Other API"
      And the following application plans:
        | Product   | Name        |
        | Other API | Normal Plan |
        | Other API | Super Plan  |
      And they go to product "Other API" application plans admin page
      Then the table looks like:
        | Name        |
        | Normal Plan |
        | Super Plan  |

    Scenario: Hiding application plans
      When they select action "Hide" of "Public Plan"
      Then they should see "Plan Public Plan was hidden"
      And the table has the following row:
        | Name        | State  |
        | Public Plan | hidden |
      And the actions of row "Public Plan" are:
        | Publish |
        | Copy    |
        | Delete  |

    Scenario: Publishing application plans
      When they select action "Publish" of "Secret Plan"
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
      Given the following application plans:
        | Product | Name                        | State     |
        | My API  | This is number One          | Hidden    |
        | My API  | Now the second one          | Hidden    |
        | My API  | Finally the last            | Published |
        | My API  | This has been bought        | Published |
        | My API  | This has been bought twice! | Published |
      When they go to product "My API" application plans admin page

    @search
    Scenario: Filtering application plans
      And they search "one" using the toolbar
      Then the table looks like:
        | Name               |
        | This is number One |
        | Now the second one |
      When they search "last" using the toolbar
      Then the table looks like:
        | Name             |
        | Finally the last |
      When they search "foooo" using the toolbar
      Then the table looks like:
        | Name |

  Rule: Sorting
    Background:
      Given the following application plans:
        | Product | Name | State     |
        | My API  | AAA  | Hidden    |
        | My API  | BBB  | Published |
        | My API  | CCC  | Published |
      When they go to product "My API" application plans admin page

    Scenario: Sorting application plans by name
      When the table is sorted by "Name"
      Then the table looks like:
        | Name |
        | AAA  |
        | BBB  |
        | CCC  |
      When the table is sorted by "Name" again
      Then the table looks like:
        | Name |
        | CCC  |
        | BBB  |
        | AAA  |

    Scenario: Sorting application plans by contracts
      Given application plan "BBB" has 2 contracts
      And application plan "CCC" has 1 contracts
      When the table is sorted by "Contract"
      Then the table looks like:
        | Name |
        | BBB  |
        | CCC  |
        | AAA  |
      When the table is sorted by "Contract" again
      Then the table looks like:
        | Name |
        | AAA  |
        | CCC  |
        | BBB  |

    Scenario: Sorting application plans by state
      Given application plan "AAA" is hidden
      And application plan "CCC" is hidden
      When the table is sorted by "State"
      Then the table looks like:
        | Name |
        | BBB  |
        | AAA  |
        | CCC  |
      When the table is sorted by "State" again
      Then the table looks like:
        | Name |
        | AAA  |
        | CCC  |
        | BBB  |
