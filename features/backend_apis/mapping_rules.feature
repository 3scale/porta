@javascript
Feature: Backend API mapping rules
  In order to integrate my backend api
  As a provider
  I want to be able to manage my mapping rules

  Background:
    Given a provider "foo.3scale.localhost"
    And a backend api
    And current domain is the admin domain of provider "foo.3scale.localhost"
    And I log in as provider "foo.3scale.localhost"

  Scenario: Sorting mapping rules
    When I go to the mapping rules index page for backend "My Backend"
    And I add a new mapping rule with method "POST" pattern "/beers" position "2" and metric "Hits"
    Then the mapping rules should be in the following order:
      | http_method | pattern | position | metric |
      | GET         | /       | 1        | hits   |
      | POST        | /beers  | 2        | hits   |
    And I add a new mapping rule with method "PUT" pattern "/mixers" position "2" and metric "Hits"
    Then the mapping rules should be in the following order:
      | http_method | pattern | position | metric |
      | GET         | /       | 1        | hits   |
      | PUT         | /mixers | 2        | hits   |
      | POST        | /beers  | 3        | hits   |
    And I add a new mapping rule with method "GET" pattern "/gins" position "1" and metric "Hits"
    Then the mapping rules should be in the following order:
      | http_method | pattern | position | metric |
      | GET         | /       | 1        | hits   |
      | GET         | /gins   | 2        | hits   |
      | PUT         | /mixers | 3        | hits   |
      | POST        | /beers  | 4        | hits   |

  Scenario: New mapping rule form can't have redirect url
    When I go to the create mapping rule page for backend "My Backend"
    Then I should not see field "Redirect URL"
