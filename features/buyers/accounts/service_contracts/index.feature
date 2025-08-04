@javascript
Feature: Audience > Accounts > Listing > Account > Service subscriptions

  As a provider, I want to see a list with a buyer's service subscriptions that is searchable and
  filterable.

  The following actions will be available:
  - Approve a pending subscription
  - Remove an existing subscription
  - Change the plan of an existing subscription
  - Subscribe to other unsubscribed services

  Background:
    Given a provider is logged in
    And a buyer "Alice"
    And the default service of the provider has name "My API"
    And the provider has "service_plans" visible
    And a product "Banana API"
    And another product "Coconut API"

  Scenario: Navigation
    Given the current page is the provider dashboard
    When they select "Audience" from the context selector
    And they follow "Listing" within the main menu's section Accounts
    And they follow "Alice"
    And they follow "0 Service Subscriptions"
    Then the current page is the buyer's service subscriptions page
    And they should see "Service subscriptions of Alice"

  Scenario: Empty view
    Given the provider has no service subscriptions
    When they go to the buyer's service subscriptions page
    Then they should see an empty state

  Scenario: Empty search
    Given the buyer is subscribed to product "Banana API"
    When they go to the buyer's service subscriptions page
    And the table is filtered with:
      | Filter  | Value       |
      | Service | Coconut API |
    Then they should see an empty search state

  Scenario: Filter subscriptions by product
    Given the buyer is subscribed to product "Banana API"
    And the buyer is subscribed to product "Coconut API"
    When they go to the buyer's service subscriptions page
    And the table should contain the following:
      | Service     | Plan    | State | Paid? |
      | Banana API  | Default | live  | free  |
      | Coconut API | Default | live  | free  |
    When the table is filtered with:
      | Filter  | Value      |
      | Service | Banana API |
    And the table should contain the following:
      | Service    | Plan    | State | Paid? |
      | Banana API | Default | live  | free  |

  Scenario: Filter subscriptions by service plan
    Given the following service plans:
      | Product     | Name  |
      | Banana API  | Basic |
      | Coconut API | Pro   |
    And the following buyers with service subscriptions signed up to the provider:
      | Buyer | Plans      |
      | Alice | Basic, Pro |
    When they go to the buyer's service subscriptions page
    And the table is filtered with:
      | Filter | Value |
      | Plan   | Pro   |
    Then the table should contain the following:
      | Service     | Plan | State | Paid? |
      | Coconut API | Pro  | live  | free  |

  Scenario: Filter subscriptions by state
    Given the buyer is subscribed to product "Banana API"
    And the buyer is subscribed to product "Coconut API"
    When they go to the buyer's service subscriptions page
    And the table is filtered with:
      | Filter | Value   |
      | State  | Pending |
    Then they should see an empty search state
    When the table is filtered with:
      | Filter | Value |
      | State  | Live  |
    Then the table should contain the following:
      | Service     | State |
      | Coconut API | live  |
      | Banana API  | live  |

  Scenario: Filter paid subscriptions
    Given the following service plans:
      | Product     | Name  | Cost per month |
      | Banana API  | Basic | 0              |
      | Coconut API | Pro   | 100            |
    And the following buyers with service subscriptions signed up to the provider:
      | Buyer | Plans      |
      | Alice | Basic, Pro |
    When they go to the buyer's service subscriptions page
    And the table is filtered with:
      | Filter    | Value |
      | Plan type | Paid  |
    Then the table should contain the following:
      | Service     | Plan | State | Paid? |
      | Coconut API | Pro  | live  | paid  |

  Scenario Outline: Ordering
    When they go to the buyer's service subscriptions page
    And the table is sorted by "<order by>"
    Then the table should be sorted by "<order by>"

    Examples:
      | order by   |
      | State      |
      | Created On |

  # Enable when sorting by plan is enabled
  @wip
  Scenario: Order by plan name
    Given the following service plans:
      | Product     | Name  |
      | Banana API  | Pro   |
      | Coconut API | Basic |
    And the following buyers with service subscriptions signed up to the provider:
      | Buyer | Plans      |
      | Alice | Basic, Pro |
    When they go to the buyer's service subscriptions page
    Then they should see the following table:
      | Service      | Plan    |
      | Banana API   | Pro     |
      | Coconut API  | Basic   |
    And the table is sorted by "Plan"
    Then they should see the following table:
      | Service      | Plan   |
      | Coconut API  | Basic  |
      | Banana API   | Pro    |

  Scenario: Ordering and filtering by service
    Given the following service plans:
      | Product     | Name  |
      | Banana API  | Basic |
      | Coconut API | Pro   |
    And the following buyers with service subscriptions signed up to the provider:
      | Buyer | Plans      | State     |
      | Alice | Basic      | suspended |
      | Alice | Pro        | live      |
    When they go to the buyer's service subscriptions page
    Then they should see the following table:
      | Service     | Plan    | State      |
      | Banana API  | Basic   | suspended  |
      | Coconut API | Pro     | live       |
    When the table is filtered with:
      | Filter  | Value      |
      | Service | Banana API |
    And the table is sorted by "State"
    Then they should see the following table:
      | Service    | Plan    | State      |
      | Banana API | Basic   | suspended  |

  Scenario: Create a new subscription
    Given the buyer is subscribed to product "Banana API"
    And the following service plans:
      | Product     | Name |
      | Coconut API | Lite |
      | Coconut API | Full |
    And they go to the buyer's service subscriptions page
    And the table should contain the following:
      | Service    | Plan    | State | Paid? |
      | Banana API | Default | live  | free  |
    When they follow "Subscribe to Coconut API"
    And there is a select "Plan" with options:
      | Default |
      | Lite    |
      | Full    |
    And the modal is submitted with:
      | Plan | Lite |
    Then they should see a toast alert with text "Service contract created successfully"
    And the table should contain the following:
      | Service     | Plan    | State | Paid? |
      | Banana API  | Default | live  | free  |
      | Coconut API | Lite    | live  | free  |

  Scenario: Change an existing subscription
    Given the buyer is subscribed to product "Banana API"
    And the following service plans:
      | Product    | Name |
      | Banana API | Lite |
      | Banana API | Full |
    And they go to the buyer's service subscriptions page
    And the table should contain the following:
      | Service    | Plan    | State | Paid? |
      | Banana API | Default | live  | free  |
    When they follow "Change Banana API subscription"
    And there is a select "Plan" with options:
      | Default |
      | Lite    |
      | Full    |
    And the modal is submitted with:
      | Plan | Full |
    Then they should see a toast alert with text "Plan of the contract was changed"
    And the table should contain the following:
      | Service    | Plan | State | Paid? |
      | Banana API | Full | live  | free  |

  Scenario: Approve a subscription
    Given the buyer is subscribed to product "Banana API"
    But the subscription is pending
    And they go to the buyer's service subscriptions page
    And the table should contain the following:
      | Service    | Plan    | State   | Paid? |
      | Banana API | Default | pending | free  |
    When they follow "Approve subscription to Banana API"
    Then they should see a toast alert with text "Service contract was approved"
    And the table should contain the following:
      | Service    | Plan    | State | Paid? |
      | Banana API | Default | live  | free  |

  @wip
  Scenario: Can't approve a subscription
    Given the buyer is subscribed to product "Banana API"
    But the subscription is pending
    And they go to the buyer's service subscriptions page
    And the table should contain the following:
      | Service    | Plan    | State   | Paid? |
      | Banana API | Default | pending | free  |
    When they follow "Approve subscription to Banana API"
    Then they should see a toast alert with text "Cannot approve service contract"
    And the table should contain the following:
      | Service    | Plan    | State   | Paid? |
      | Banana API | Default | pending | free  |

  Scenario: Unsubscribe from a service
    Given the buyer is subscribed to product "Banana API"
    And they go to the buyer's service subscriptions page
    And the table should contain the following:
      | Service    | Plan    | State | Paid? |
      | Banana API | Default | live  | free  |
    When they follow "Unsubscribe from Banana API"
    And confirm the dialog
    Then they should see a toast alert with text "Successfully unsubscribed from the service"
    And they should see an empty search state
  # TODO: should be -> And they should see an empty state

  Scenario: Can't delete the a subscription if there is an application
    Given the following application plan:
      | Product    | Name  |
      | Banana API | Basic |
    Given the following application:
      | Buyer | Product    | Name   | Plan  |
      | Alice | Banana API | My App | Basic |
    And the buyer is subscribed to product "Banana API"
    And they go to the buyer's service subscriptions page
    When they follow "Unsubscribe from Banana API"
    And confirm the dialog
    Then they should see a toast alert with text "Cannot unsubscribe from the service"
    And the table should contain the following:
      | Service    | Plan    | State | Paid? |
      | Banana API | Default | live  | free  |
