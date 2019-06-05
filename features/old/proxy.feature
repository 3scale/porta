@javascript
Feature: Proxy integration
  In order to integrate with 3scale via a on-premise proxy
  As a provider
  I want to download config files from the inteface

  Background:
    Given all the rolling updates features are off
    And I have apicast_v1 feature enabled
    And I have apicast_v2 feature enabled
    And I have oauth_api feature enabled
    Given a provider "foo.example.com"
    And a default service of provider "foo.example.com" has name "one"
    And the service "one" of provider "foo.example.com" has deployment option "self_managed"
    And current domain is the admin domain of provider "foo.example.com"
    And I log in as provider "foo.example.com"
    And apicast registry is stubbed
    And I go to the integration show page for service "one"
    And I press "Revert to the old APIcast"

  Scenario: Download Nginx Config without public base URL
    When I go to the integration page for service "one"
    And I follow "Download the NGINX Config files"
    Then I should be offered to download an "application/zip" file

  # regression for http://3scale.airbrake.io/errors/54042831
  Scenario: Download Nginx Config
    When I go to the integration page for service "one"
    And I fill in "proxy_endpoint" with "http://public.example.com"
    And I press "Update Production Configuration"
    And I follow "Download the NGINX Config files"
    Then I should be offered to download an "application/zip" file

  Scenario: Sandbox testing enabled by default
    When I go to the integration page for service "one"
    Then I should see button to "Test"

  Scenario: Sandbox disabled for oauth
    When provider "foo.example.com" uses backend oauth in his default service
    And I go to the integration page for service "one"
    Then I should see button to "Update Staging Configuration"

  Scenario: Download Nginx Config for oauth
    When provider "foo.example.com" uses backend oauth in his default service
    When I go to the integration page for service "one"
    And I fill in "proxy_endpoint" with "http://public.example.com"
    And I press "Update Production Configuration"
    And I follow "Download the NGINX Config files"
    Then I should be offered to download an "application/zip" file

  Scenario: Redirect url with rolling updates
    And I go to the integration page for service "one"
    Then I should not see "Redirect"

    When I have proxy_pro feature enabled
    And I go to the integration page for service "one"
    Then I should see "Redirect"

  Scenario: Edit endpoint with proxy_pro
    Given all the rolling updates features are off
    When I have proxy_pro feature enabled
     And I have async_apicast_deploy feature enabled
    Then I can edit the proxy public endpoint

  @javascript
  Scenario: Restore to default API Backend
    Given I'm using a custom API Backend
    Then I should be able to switch back to using the default API Backend


  @javascript @selenium
  Scenario: Got some fancy policy chain
    And I go to the integration show page for service "one"
    And I press "Start using the latest APIcast"
    When I have policies feature enabled
    And I go to the integration page for service "one"
    Then I should see the Policy Chain


  Scenario: Got error message when APIcast registry is not setup properly
    And apicast registry is undefined
    And I go to the integration show page for service "one"
    And I press "Start using the latest APIcast"
    When I have policies feature enabled
    And I go to the integration page for service "one"
    Then I should see "A valid APIcast Policies endpoint must be provided"

  @javascript
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
      | PUT         | /mixers | 1     | hits   |
      | GET         | /       | 1     | hits   |
      | POST        | /beers  | 2     | hits   |
