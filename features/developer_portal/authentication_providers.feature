Feature: Authenticate using external Authentication Providers
  In order to login and/or signup with oauth/oidc providers
  As a buyer

  Background:
    Given a provider exists
    And the provider account allows signups
    And as a developer

  @javascript @selenium
  Scenario: Signup with Auth0
    Given the provider has the authentication provider "Auth0" published
    And I go to the login page
    Then I should see the link "Authenticate with Auth0" containing "auth0.com client_id= redirect_uri= response_type= scope=openid+profile+email" in the URL

