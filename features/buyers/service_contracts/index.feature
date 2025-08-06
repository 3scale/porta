@javascript
Feature: Audience > Accounts > Service subscriptions

  As a provider, I want to see a list of my customers' service subscriptions that is searchable and
  filterable

  Background:
    Given a provider is logged in
    And the default service of the provider has name "My API"
    And the provider has "service_plans" visible
    And a product "Elephant Taming"
    And another product "Zeebra Stripe Drawing"

  Scenario: Navigation
    Given the current page is the provider dashboard
    When they select "Audience" from the context selector
    And they follow "Subscriptions" within the main menu's section Accounts
    Then the current page is the provider service subscriptions page

  Scenario: Empty view
    Given the provider has no service subscriptions
    When they go to the provider service subscriptions page
    Then they should see an empty state

  Scenario: Empty search
    Given a buyer "Mouse"
    And the buyer is subscribed to product "Elephant Taming"
    When they go to the provider service subscriptions page
    And the table is filtered with:
      | Filter  | Value                 |
      | Service | Zeebra Stripe Drawing |
    Then they should see an empty search state

  Scenario: Filter subscriptions by product
    Given a buyer "Mouse"
    And the buyer is subscribed to product "Elephant Taming"
    And the buyer is subscribed to product "Zeebra Stripe Drawing"
    When they go to the provider service subscriptions page
    And the table should contain the following:
      | Account | Service               | Plan    | State | Paid? |
      | Mouse   | Elephant Taming       | Default | live  | free  |
      | Mouse   | Zeebra Stripe Drawing | Default | live  | free  |
    When the table is filtered with:
      | Filter  | Value           |
      | Service | Elephant Taming |
    And the table should contain the following:
      | Account | Service         | Plan    | State | Paid? |
      | Mouse   | Elephant Taming | Default | live  | free  |

  @search
  Scenario: Filter subscriptions by account
    Given a buyer "Ben"
    And the buyer is subscribed to product "My API"
    And a buyer "Bender"
    And the buyer is subscribed to product "My API"
    And a buyer "Leela"
    And the buyer is subscribed to product "My API"
    When they go to the provider service subscriptions page
    And the table is filtered with:
      | Filter  | Value |
      | Account | Ben   |
    Then the table should contain the following:
      | Account | Service | Plan    | State | Paid? |
      | Ben     | My API  | Default | live  | free  |
      | Bender  | My API  | Default | live  | free  |

  Scenario: Filter subscriptions by service plan
    Given the following service plans:
      | Product               | Name  |
      | Elephant Taming       | Basic |
      | Zeebra Stripe Drawing | Pro   |
    And the following buyers with service subscriptions signed up to the provider:
      | Buyer  | Plans      |
      | Ben    | Basic, Pro |
      | Bender | Basic      |
      | Leela  | Pro        |
    When they go to the provider service subscriptions page
    And the table is filtered with:
      | Filter | Value |
      | Plan   | Pro   |
    Then the table should contain the following:
      | Account | Service               | Plan | State | Paid? |
      | Ben     | Zeebra Stripe Drawing | Pro  | live  | free  |
      | Leela   | Zeebra Stripe Drawing | Pro  | live  | free  |

  Scenario: Filter subscriptions by state
    Given a buyer "Bender"
    And the buyer is subscribed to product "Elephant Taming"
    And a buyer "Leela"
    And the buyer is subscribed to product "Zeebra Stripe Drawing"
    When they go to the provider service subscriptions page
    And the table is filtered with:
      | Filter | Value   |
      | State  | Pending |
    Then they should see an empty search state
    When the table is filtered with:
      | Filter | Value |
      | State  | Live  |
    Then the table should contain the following:
      | Account | Service               | State |
      | Leela   | Zeebra Stripe Drawing | live  |
      | Bender  | Elephant Taming       | live  |

  @wip
  Scenario: Filter paid subscriptions
    Given the following service plans:
      | Product | Name  | Cost per month |
      | My API  | Basic | 0              |
      | My API  | Pro   | 100            |
    And the following buyers with service subscriptions signed up to the provider:
      | Buyer | Plans |
      | Leela | Basic |
      | Amy   | Pro   |
    When they go to the provider service subscriptions page
    And the table is filtered with:
      | Filter    | Value |
      | Plan type | Paid  |
    Then the table should contain the following:
      | Account | Service | Plan | State | Paid? |
      | Amy     | My API  | Pro  | live  | paid  |

  Scenario Outline: Ordering
    When they go to the provider service subscriptions page
    And the table is sorted by "<order by>"
    Then the table should be sorted by "<order by>"

    Examples:
      | order by   |
      | Account    |
      | State      |
      | Created On |

  Scenario: Ordering and filtering by service
    Given the following service plan:
      | Product          | Name         |
      | Elephant Taming  | Service Plan |
    Given a buyer "First"
    And a buyer "Second"
    And buyer "First" is subscribed to plan "Service Plan"
    And buyer "Second" is subscribed to plan "Service Plan"
    And buyer "First" plan "Service Plan" contract gets suspended
    When they go to the provider service subscriptions page
    When the table is filtered with:
      | Filter  | Value           |
      | Service | Elephant Taming |
    And the table is sorted by "State"
    And the table should contain the following:
      | Account  | Service         | Plan         | State     |
      | First    | Elephant Taming | Service Plan | live      |
      | Second   | Elephant Taming | Service Plan | suspended |

  # Enable when sorting by plan is enabled
  @wip
  Scenario: Order by plan name
    Given a buyer "Someone"
    And the following service plans:
      | Product               | Name  |
      | Elephant Taming       | Pro   |
      | Zeebra Stripe Drawing | Basic |
    And the following buyers with service subscriptions signed up to the provider:
      | Buyer   | Plans      |
      | Someone | Basic, Pro |
    When they go to the buyer's service subscriptions page
    Then the table should contain the following:
      | Service                | Plan    |
      | Elephant Taming        | Pro     |
      | Zeebra Stripe Drawing  | Basic   |
    And the table is sorted by "Plan"
    Then the table should contain the following:
      | Service                | Plan   |
      | Zeebra Stripe Drawing  | Basic  |
      | Elephant Taming        | Pro    |
