Feature: Providers's applications searching, sorting and filtering
  In order to quickly find specific set of appplications
  As a provider
  I want to search, filter and sort applications

  Background:
    Given a provider "foo.3scale.localhost"
    And provider "foo.3scale.localhost" has multiple applications enabled
    And provider "foo.3scale.localhost" has "finance" switch visible
    And a default application plan of provider "foo.3scale.localhost"
    And a buyer "bob" signed up to provider "foo.3scale.localhost"
    And a buyer "jane" signed up to provider "foo.3scale.localhost"

    And the provider "foo.3scale.localhost" has following application plans:
      | Name      | Cost per month | Setup fee |
      | Cheap     | 0              | 0         |
      | Expensive | 100            | 10        |

    And the provider "foo.3scale.localhost" has the following applications:
      | Buyer | Name    | Plan      |
      | bob   | BobApp  | Cheap     |
      | jane  | JaneApp | Expensive |

    And current domain is the admin domain of provider "foo.3scale.localhost"
    And I am logged in as provider "foo.3scale.localhost"

  Scenario: Search
    When I am on the applications admin page
    Then I should see following table:
      | Name    | Account |
      | JaneApp | jane    |
      | BobApp  | bob     |
    When I search for:
      | Name | Plan  | Paid? | State |
      | bob  | Cheap | free  | live  |
    And I follow "Name" within table header
    Then I should see following table:
      | Name ▲  | Account |
      | BobApp  | bob     |

  Scenario: Search scoped by service
    When I follow "2 Applications"
    Then I should see following table:
      | Name    | Account |
      | JaneApp | jane    |
      | BobApp  | bob     |
    When I search for:
      | Name | Plan  | Paid? | State |
      | bob  | Cheap | free  | live  |
    And I follow "Name" within table header
    Then I should see following table:
      | Name ▲  | Account |
      | BobApp  | bob     |


  Scenario: Listing
    Given the provider "foo.3scale.localhost" has the following applications:
    | Buyer | Name     | Plan  |
    | jane  | CheapApp | Cheap |

    When I am on the applications admin page with 1 record per page
    Then I should see 3 pages
    When I search for:
      | Plan  |
      | Cheap |
    And I follow "Account" within table header
    And I should see following table:
      | Account ▲ |
      | bob       |
      | jane      |


  Scenario Outline: Ordering
    Given I am on the applications admin page
    When I search for:
      | Name | Plan  | Paid? | State |
      | bob  | Cheap | free  | live  |
    And I follow "<order by>" within table header
    Then I should see "<order by> ▲"

    Examples:
      | order by   |
      | Name       |
      | Account    |
      | Plan       |
      | State      |
      | Created At |
