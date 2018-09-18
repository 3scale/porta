Feature: SSO
  In order to sign in using OAuth2
  As an user

  Background:
    Given Provider has setup RH SSO
    And As a developer, I login through RH SSO

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