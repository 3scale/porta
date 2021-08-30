@search
Feature: Providers's subscription searching, sorting and filtering
  In order to quickly find specific set of subscriptions
  As a provider
  I want to search, filter and sort subscriptions

  Background:
    Given a provider "foo.3scale.localhost"
      And provider "foo.3scale.localhost" has "service_plans" visible
      And a default service of provider "foo.3scale.localhost" has name "Fancy API"
      And a service "New Service" of provider "foo.3scale.localhost"
      And a default service plan "Basic" of service "Fancy API"
      And a service plan "Unpublished" of service "New Service"

    Given the following buyers with service subscriptions signed up to provider "foo.3scale.localhost":
      | name | plans              |
      | bob  | Basic, Unpublished |
      | jane | Basic              |
      | mike | Unpublished        |

    And current domain is the admin domain of provider "foo.3scale.localhost"
    And I am logged in as provider "foo.3scale.localhost"

  Scenario: Search
    When I am on the subscriptions admin page
    When I search for:
      | Plan  | Paid? | State |
      | Basic | free  | live  |
    And I follow "Account" within table header
    Then I should see following table:
     | Account ▲ |
     | bob       |
     | jane      |

  Scenario: Listing
    When I am on the subscriptions admin page with 1 record per page
    Then I should see 4 pages
    When I search for:
      | Plan  |
      | Basic |
    And I follow "Account" within table header
    And I should see following table:
      | Account ▲ |
      | bob       |
      | jane      |

  Scenario Outline: Ordering
    Given I am on the subscriptions admin page
    When I search for:
      | Plan        | Paid? | State |
      | Unpublished | free  | live  |
    And I follow "<order by>" within table header
    Then I should see "<order by> ▲"

    Examples:
      | order by   |
      | Account    |
      | Plan       |
      | State      |
      | Created On |
