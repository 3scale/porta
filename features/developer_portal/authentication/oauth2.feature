Feature: OAuth2
  In order to sign in using OAuth2
  As a user

  Background:
    Given Provider has setup RH SSO
    And As a developer, I see RH-SSO login option on the login page

  Scenario: All required data in OAuth2 response
    Given the Oauth2 user has all the required fields
    When I authenticate by Oauth2
    And I visit a page showing the current user's SSO data
    Then the html should contain the SSO data

  Scenario: Missing required data in OAuth response
    Given the Oauth2 user does not have all the required fields
    When I authenticate by Oauth2
    And I fill and send the missing data for the signup page
    And I visit a page showing the current user's SSO data
    Then the html should contain the SSO data

  @recaptcha
  Scenario: Recaptcha doesn't break the OAuth workflow
    Given the provider has bot protection enabled
    And the Oauth2 user has all the required fields
    When the buyer authenticates by OAuth2
    Then the page should contain "Signed up successfully"
