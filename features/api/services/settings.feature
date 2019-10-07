Feature: Integration Settings
  In order to configure my Product API
  As a provider
  I want to set my API deployment and authentication options


  Background:
    Given a provider "foo.example.com"
    And current domain is the admin domain of provider "foo.example.com"


  Scenario: Integration Settings options (Rolling updates Service Mesh OFF)
    Given I log in as provider "foo.example.com"
    And I have rolling updates "service_mesh_integration,apicast_oidc" disabled
    And I go to the settings page for service "API" of provider "foo.example.com"
    Then I should see within "#service_deployment_option_input" the following:
      | name                           |
      | APIcast a 3scale managed       |
      | APIcast self-managed           |

    And I should see within "#service_proxy_authentication_method_input" the following:
      | name                     |
      | API Key (user_key)       |
      | App_ID and App_Key Pair  |


  Scenario: Integration Settings options (Rolling updates ON)
    Given I log in as provider "foo.example.com"
    And I go to the settings page for service "API" of provider "foo.example.com"
    Then I should see within "#service_deployment_option_input" the following:
      | name                           |
      | APIcast a 3scale managed       |
      | APIcast self-managed           |
      | Istio                          |

    And I should see within "#service_proxy_authentication_method_input" the following:
      | name                     |
      | API Key (user_key)       |
      | App_ID and App_Key Pair  |
      | OpenID Connect           |

  @javascript
  Scenario: Integration Settings and authentication method interaction
    Given I log in as provider "foo.example.com"
    And I go to the settings page for service "API" of provider "foo.example.com"

    When I click on the label "APIcast self-managed"

    And I click on the label "API Key (user_key)"
    Then I should see "API KEY (USER_KEY) BASICS"
    And I should see "CREDENTIALS LOCATION"
    And I should see "GATEWAY RESPONSE"

    When I click on the label "App_ID and App_Key Pair"
    Then I should see "APP_ID AND APP_KEY PAIR BASICS"
    And I should see "CREDENTIALS LOCATION"
    And I should see "GATEWAY RESPONSE"

    When I click on the label "OpenID Connect"
    Then I should see "OPENID CONNECT (OIDC) BASICS"
    And I should see "OIDC AUTHORIZATION FLOW"
    And I should see "JSON WEB TOKEN (JWT) CLAIM WITH CLIENTID"
    And I should see "GATEWAY RESPONSE"


    When I click on the label "Istio"

    And I click on the label "API Key (user_key)"
    Then I should not see "API KEY (USER_KEY) BASICS"
    And I should not see "CREDENTIALS LOCATION"
    And I should not see "SECURITY"
    And I should not see "GATEWAY RESPONSE"

    When I click on the label "App_ID and App_Key Pair"
    Then I should not see "APP_ID AND APP_KEY PAIR BASICS"
    And I should not see "CREDENTIALS LOCATION"
    And I should not see "SECURITY"
    And I should not see "GATEWAY RESPONSE"

    When I click on the label "OpenID Connect"
    Then I should see "OPENID CONNECT (OIDC) BASICS"
    And I should see "OIDC AUTHORIZATION FLOW"
    And I should not see "CREDENTIALS LOCATION"
    And I should not see "SECURITY"
    And I should not see "GATEWAY RESPONSE"
