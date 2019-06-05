@javascript
Feature: Manage Authentication Providers
  In order to allow my buyers login with oauth2 providers
  As a provider

  Background:
    Given a provider is logged in

  Scenario: With plan by default add github
    When I visit the "GitHub" authentication provider edit page
    Then I should be on the upgrade notice page for "branding"

  Scenario: With plan by default add auth0
    When I visit the "Auth0" authentication provider page
    Then I should be on the upgrade notice page for "iam_tools"

  Scenario: With branding allowed add github
    Given the provider has "branding" switch allowed
    When I visit the "GitHub" authentication provider edit page
    Then I should see "Customize GitHub"

  Scenario: With branding allowed add auth0
    Given the provider has "branding" switch allowed
    When I visit the "Auth0" authentication provider page
    Then I should be on the upgrade notice page for "iam_tools"

  Scenario: With iam_tools allowed add auth0
    Given the provider has "iam_tools" switch allowed
    When I visit the "Auth0" authentication provider page
    Then I press "Create Auth0"

  Scenario: With iam_tools allowed add github
    Given the provider has "iam_tools" switch allowed
    When I visit the "GitHub" authentication provider edit page
    Then I should be on the upgrade notice page for "branding"
