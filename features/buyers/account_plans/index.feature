@javascript
Feature: Account plans index page

  In order to manage account plans from the index page, I want to perform the following
  actions: create, copy, edit, delete, publish and hide. Moreover, I want to sort the table
  by name, no. of apps and state.

  Background:
    Given a provider is logged in
    And the provider has "account_plans" allowed
    But the provider has no account plans

  Scenario: Navigation via context selector
    When they select "Audience" from the context selector
    And follow "Account Plans" within the main menu
    Then the current page is the account plans admin page

  Rule: Warning
    Scenario: No published or default plan
      Given the following account plan:
        | Issuer               | Name | State  | Default |
        | foo.3scale.localhost | Free | Hidden | false   |
      When they go to the account plans admin page
      Then the following warning should be visible:
        """
        You have no published or default plan. Without at least one of those being present, users
        cannot sign up.
        """

    Scenario: No published plans but the default plan is set
      Given the following account plan:
        | Issuer               | Name | State  | Default |
        | foo.3scale.localhost | Free | Hidden | true    |
      When they go to the account plans admin page
      Then there should not be any wanrning

    Scenario: A plan is published but none default
      Given the following account plan:
        | Issuer               | Name | State     |
        | foo.3scale.localhost | Free | Published |
      When they go to the account plans admin page
      Then there should not be any wanrning

  Rule: Managing plans
    Background:
      Given the following account plan:
        | Issuer               | Name        | State     |
        | foo.3scale.localhost | Public Plan | Published |
        | foo.3scale.localhost | Secret Plan | Hidden    |
      And they go to the account plans admin page

    Scenario: Copying account plans
      When they select action "Copy" of "Public Plan"
      Then they should see "Plan copied"
      And the table has the following rows:
        | Name               | Contracts | State     |
        | Public Plan (copy) | 0         | published |

      When they select action "Copy" of "Secret Plan"
      Then they should see "Plan copied"
      And the table has the following rows:
        | Name               | Contracts | State     |
        | Secret Plan (copy) | 0         | hidden    |

    Scenario: Deleting account plans
      Given account plan "Public Plan" has 0 contracts
      And they go to the account plans admin page
      When they select action "Delete" of "Public Plan"
      And confirm the dialog
      Then they should see "The plan was deleted"
      And the table should contain the following:
        | Name        | Contracts | State  |
        | Secret Plan | 0         | hidden |

    Scenario: Plans in use can't be deleted
      Given account plan "Public Plan" has 1 contract
      And they go to the account plans admin page
      Then the actions of row "Public Plan" are:
        | Hide |
        | Copy |

    Scenario: Hiding account plans
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

    Scenario: Publishing account plans
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
      Given the following account plans:
        | Issuer               | Name                        | State     |
        | foo.3scale.localhost | This is number One          | Hidden    |
        | foo.3scale.localhost | Now the second one          | Hidden    |
        | foo.3scale.localhost | Finally the last            | Published |
        | foo.3scale.localhost | This has been bought        | Published |
        | foo.3scale.localhost | This has been bought twice! | Published |
      And they go to the account plans admin page

    @search
    Scenario: Filtering account plans
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
      Given the following account plans:
        | Issuer               | Name | State     |
        | foo.3scale.localhost | AAA  | Hidden    |
        | foo.3scale.localhost | BBB  | Published |
        | foo.3scale.localhost | CCC  | Published |
      And they go to the account plans admin page

    Scenario: Sorting account plans by name
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

    Scenario: Sorting account plans by contracts
      Given account plan "BBB" has 2 contracts
      And account plan "CCC" has 1 contract
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

    Scenario: Sorting account plans by state
      Given account plan "AAA" is hidden
      And account plan "CCC" is hidden
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

  Rule: Account plans disabled
    Background:
      Given the provider has "account_plans" denied

    Scenario: Account plans are hidden
      When they select "Audience" from the context selector
      Then they should not see "Account Plans" within the main menu
