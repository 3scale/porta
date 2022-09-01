@javascript
Feature: Product mapping rules
  In order to configure API gateway access control
  As a provider
  I want to be able to manage my mapping rules

  Background:
    Given all the rolling updates features are off
    And I have oauth_api feature enabled
    Given a provider "foo.3scale.localhost"
    And a default service of provider "foo.3scale.localhost" has name "one"
    And the service "one" of provider "foo.3scale.localhost" has deployment option "self_managed"
    And current domain is the admin domain of provider "foo.3scale.localhost"
    And I log in as provider "foo.3scale.localhost"
    And apicast registry is stubbed
    And the default proxy does not use apicast configuration driven

  Scenario: Sorting mapping rules
    When I go to the mapping rules index page for service "one"
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
      | GET         | /gins   | 1        | hits   |
      | GET         | /       | 2        | hits   |
      | PUT         | /mixers | 3        | hits   |
      | POST        | /beers  | 4        | hits   |

  Scenario: New mapping rule form with proxy pro
    Given I have proxy_pro feature enabled
    When I go to the create mapping rule page for service "one"
    Then I should see field "Redirect URL"

  Scenario: New mapping rule form without proxy pro
    Given I have proxy_pro feature disabled
    When I go to the create mapping rule page for service "one"
    Then I should not see field "Redirect URL"

  @search
  Scenario: Pagination when search results are multi-page
    Given a service "ManyRules"
    And the service "ManyRules" has 30 mapping rules starting with pattern "/test"
    When I go to the mapping rules index page for service "ManyRules"
    And I search mapping rules for pattern "/test"
    Then I should see 2 pages
