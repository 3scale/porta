Feature: Providers's applications searching, sorting and filtering
  In order to quickly find specific set of appplications
  As a provider
  I want to search, filter and sort applications

  Background:
    Given a provider "foo.example.com"
    And provider "foo.example.com" has multiple applications enabled
    And provider "foo.example.com" has "finance" switch visible
    And a default application plan of provider "foo.example.com"
    And a buyer "bob" signed up to provider "foo.example.com"
    And a buyer "jane" signed up to provider "foo.example.com"

    And the provider "foo.example.com" has following application plans:
      | Name      | Cost per month | Setup fee |
      | Cheap     | 0              | 0         |
      | Expensive | 100            | 10        |

    And the provider "foo.example.com" has the following applications:
      | Buyer | Name    | Plan      |
      | bob   | BobApp  | Cheap     |
      | jane  | JaneApp | Expensive |

    And current domain is the admin domain of provider "foo.example.com"
    And I am logged in as provider "foo.example.com"

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
    When I follow "API" within the main menu
    And I follow "Latest Apps"
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
    Given the provider "foo.example.com" has the following applications:
    | Buyer | Name     | Plan  |
    | jane  | CheapApp | Cheap |

    When I am on the applications admin page with 1 record per page
    Then I should see 3 pages
    When I search for:
      | Plan  |
      | Cheap |
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
