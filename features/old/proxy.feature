Feature: Proxy integration
  In order to integrate with 3scale via a on-premise proxy
  As a provider
  I want to download config files from the inteface

  Background:
    Given all the rolling updates features are off
    And I have apicast_v2 feature enabled
    And I have oauth_api feature enabled
    Given a provider "foo.3scale.localhost"
    And a default service of provider "foo.3scale.localhost" has name "one"
    And the service "one" of provider "foo.3scale.localhost" has deployment option "self_managed"
    And current domain is the admin domain of provider "foo.3scale.localhost"
    And I log in as provider "foo.3scale.localhost"
    And apicast registry is stubbed
    And the default proxy does not use apicast configuration driven

  @javascript
  Scenario: Got some fancy policy chain
    When I go to the integration show page for service "one"
    And I follow "Policies"
    Then I should see the Policy Chain

  Scenario: Got error message when APIcast registry is not setup properly
    And apicast registry is undefined
    And I go to the integration show page for service "one"
    And I press "Update Service"
    And I follow "Policies"
    Then I should see "A valid APIcast Policies endpoint must be provided"

  # TODO: THREESCALE-3759 fix this test, refer to https://github.com/3scale/porta/pull/2274
  @wip
  Scenario: Sorting mapping rules
    And I go to the integration show page for service "one"
    And I follow "Mapping Rules"
    And I add a new mapping rule with method "POST" pattern "/beers" delta "2" and metric "Hits"
    And I add a new mapping rule with method "PUT" pattern "/mixers" delta "2" and metric "Hits"
    And I add a new mapping rule with method "GET" pattern "/gins" delta "1" and metric "Hits"
    Then the mapping rules should be in the following order:
      | http_method | pattern | delta | metric |
      | POST        | /gins   | 1     | hits   |
      | GET         | /       | 2     | hits   |
      | PUT         | /mixers | 3     | hits   |
      | POST        | /beers  | 4     | hits   |
