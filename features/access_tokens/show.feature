Feature: Access tokens
  As a admin
  I'd like to see the access tokens page correctly

  Scenario: I should be able to see all scopes
    Given a provider "foo.3scale.localhost"
    And an active admin "alex" of account "foo.3scale.localhost"
    And current domain is the admin domain of provider "foo.3scale.localhost"
    When I log in as provider "alex"
    And I go to the provider personal page
    And I follow "Tokens"
    And I follow "Add Access Token"
    Then I should see "Billing API"
    Then I should see "Account Management API"
    Then I should see "Analytics API"
