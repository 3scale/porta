@javascript
Feature: Backend API mapping rules
  In order to integrate my backend api
  As a provider
  I want to be able to manage my mapping rules

  Background:
    Given a provider is logged in
    And a backend

  Scenario: Sorting mapping rules
    When I go to the mapping rules index page for backend "My Backend"
    And I add a new mapping rule with method "POST" pattern "/beers" position "2" and metric "Hits"
    Then they should see a toast alert with text "Mapping rule was created"
    And the mapping rules should be in the following order:
      | http_method | pattern | position | metric |
      | GET         | /       | 1        | hits   |
      | POST        | /beers  | 2        | hits   |
    And I add a new mapping rule with method "PUT" pattern "/mixers" position "2" and metric "Hits"
    Then they should see a toast alert with text "Mapping rule was created"
    And the mapping rules should be in the following order:
      | http_method | pattern | position | metric |
      | GET         | /       | 1        | hits   |
      | PUT         | /mixers | 2        | hits   |
      | POST        | /beers  | 3        | hits   |
    And I add a new mapping rule with method "GET" pattern "/gins" position "1" and metric "Hits"
    Then they should see a toast alert with text "Mapping rule was created"
    And the mapping rules should be in the following order:
      | http_method | pattern | position | metric |
      | GET         | /       | 1        | hits   |
      | GET         | /gins   | 2        | hits   |
      | PUT         | /mixers | 3        | hits   |
      | POST        | /beers  | 4        | hits   |

  Scenario: New mapping rule form can't have redirect url
    When I go to the create mapping rule page for backend "My Backend"
    Then I should not see field "Redirect URL"

  @search
  Scenario: Pagination when search results are multi-page
    Given a backend "ManyRules"
    And the backend has 30 mapping rules starting with pattern "/test"
    When they go to the mapping rules index page for backend "ManyRules"
    And search "/test" using the toolbar
    Then they should see 2 pages
