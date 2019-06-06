@search @javascript
Feature: Providers's subscription searching, sorting and filtering
  In order to quickly find specific set of subscriptions
  As a provider
  I want to search, filter and sort subscriptions

  Background:
    Given a provider "foo.example.com"
      And provider "foo.example.com" has "service_plans" visible
      And a default service of provider "foo.example.com" has name "Fancy API"
      And a service "New Service" of provider "foo.example.com"
      And a default service plan "Basic" of service "Fancy API"
      And a service plan "Unpublished" of service "New Service"

    Given the following buyers with service subscriptions signed up to provider "foo.example.com":
      | name | plans              |
      | bob  | Basic, Unpublished |
      | jane | Basic              |
      | mike | Unpublished        |

    And current domain is the admin domain of provider "foo.example.com"
    And I am logged in as provider "foo.example.com"

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
    Then I should see 2 pages
    And I follow "Account" within table header
    And I should see following table:
      | Account ▲ |
      | bob       |
    When I look at 2nd page
    Then I should see following table:
      | Account ▲ |
      | jane      |
    And I should see 2 pages

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
