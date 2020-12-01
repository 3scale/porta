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

  # TODO: THREESCALE-3759 fix this test, refere to https://github.com/3scale/porta/pull/2274
  @javascript @wip
  Scenario: Sorting mapping rules
    And I go to the integration show page for service "one"
    And I press "Start using the latest APIcast"
    And I go to the integration page for service "one"
    And I toggle "Mapping Rules"
    And I add a new mapping rule with method "POST" pattern "/beers" delta "2" and metric "hits"
    And I add a new mapping rule with method "PUT" pattern "/mixers" delta "1" and metric "hits"
    And I drag the last mapping rule to the position 1
    And I save the proxy config
    Then the mapping rules should be in the following order:
      | http_method | pattern | delta | metric |
      | POST        | /beers  | 2     | hits   |
      | GET         | /       | 1     | hits   |
      | PUT         | /mixers | 1     | hits   |
