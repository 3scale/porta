Feature: API Settings
  In order to configure my API usage
  As a provider
  I want to have a nice API settings control panel

  Background:
    Given a provider "foo.3scale.localhost"
    And current domain is the admin domain of provider "foo.3scale.localhost"
    And apicast registry is stubbed

  Scenario: Referrer filtering on backend v2
    Given provider "foo.3scale.localhost" uses backend v2 in his default service
      And I have rolling updates "api_as_product" disabled
      And I log in as provider "foo.3scale.localhost"
      And I go to the settings page for service "API" of provider "foo.3scale.localhost"
     And I check "Require referrer filtering"
     And I press "Update Service"
    Then I should see "Service information updated"

  Scenario: Changing the backend version including OIDC option
    Given provider "foo.3scale.localhost" uses backend v2 in his default service
    And I have rolling updates "api_as_product" disabled
    And provider "foo.3scale.localhost" has multiple applications enabled
    And a default application plan of provider "foo.3scale.localhost"
    And a buyer "bob" signed up to provider "foo.3scale.localhost"
    And buyer "bob" has application "MegaWidget"
    And I log in as provider "foo.3scale.localhost"
    And I go to the integration show page for service "API" of provider "foo.3scale.localhost"
    And I follow "edit integration settings"
    When I click on the label "APIcast self-managed"
    When I click on the label "Use OpenID Connect for any OAuth 2.0 flow."
    And I press "Update Service" and I confirm dialog box
    Then I should see "Service information updated"
    And I follow "add the base URL of your API and save the configuration."
    And I toggle "Authentication Settings"
    Then I should see "OpenID Connect Issuer"
    Then I should not see "OAuth Authorization Endpoint"
    Given the default proxy uses apicast configuration driven
    When I go to the integration show page for service "API" of provider "foo.3scale.localhost"
    And I follow "edit integration settings"
    And I click on the label "API Key (user_key)"
    And I press "Update Service" and I confirm dialog box
    Then I should see "Service information updated"
    And I go to the provider side "MegaWidget" application page
    Then I should see "User Key"

  Scenario: API settings don't crash when APICAST_REGISTRY_URL is undefined
    Given apicast registry is undefined
    And I have rolling updates "api_as_product" disabled
    When I log in as provider "foo.3scale.localhost"
    And I go to the integration show page for service "API" of provider "foo.3scale.localhost"
    And I follow "add the base URL of your API and save the configuration."
    Then I should see "Integration"
