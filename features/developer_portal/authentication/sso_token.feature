Feature: SSO Token
  In order to sign in to developer portal using SSO token
  As a buyer

  Background:
    Given a provider "foo.3scale.localhost"
    And provider "foo.3scale.localhost" has multiple applications enabled
    And a buyer "bob" signed up to provider "foo.3scale.localhost"
    And the current domain is foo.3scale.localhost

  Scenario: Buyer can't login with an invalid token
    Given another provider generated a sso token for another buyer
    When the buyer authenticates by SSO Token
    Then the page should contain "Invalid SSO Token"

  Scenario: Buyer can't login with an expired token
    Given the provider generated a sso token for the buyer, valid for 10 minutes
    And 15 minutes pass
    When the buyer authenticates by SSO Token
    Then the page should contain "Token Expired"

  Scenario: Buyer can login with a valid token
    Given the provider generated a sso token for the buyer
    When the buyer authenticates by SSO Token
    Then the page should contain "Signed in successfully"

  @recaptcha
  Scenario: Buyer can login when recaptcha is enabled
    Given the provider generated a sso token for the buyer
    And the provider has bot protection enabled
    And the client will be marked as a bot
    When the buyer authenticates by SSO Token
    Then the page should contain "Signed in successfully"
