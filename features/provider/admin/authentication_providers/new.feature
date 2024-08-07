@javascript
Feature: Audience > Developer Portal > Settings > SSO Integrations > > New

  Background:
    Given a provider is logged in
    And the provider has "branding" switch allowed
    And the provider has "iam_tools" switch allowed

  Scenario: Navigation
    Given they go to the developer portal users sso integrations page
    When they follow "Red Hat Single Sign-On"
    Then the current page is the developer portal new sso integration page for "keycloak"

  Scenario: Create RH SSO new integration
    Given they go to the developer portal new sso integration page for "keycloak"
    When the form is submitted with:
      | Client        | Doctor                                     |
      | Client Secret | tardis                                     |
      | Realm         | https://rh-sso.doctor.com/auth/realms/demo |
    Then they should see the flash message "Authentication provider created"
    And the current page is the developer portal edit integration page
    And should see "Customize Red Hat Single Sign-On"

  Scenario: Create Auth0 new integration
    Given they go to the developer portal new sso integration page for "auth0"
    When the form is submitted with:
      | Client        | Doctor                   |
      | Client Secret | tardis                   |
      | Site          | https://doctor.auth0.com |
    Then they should see the flash message "Authentication provider created"
    And the current page is the developer portal edit integration page
    And should see "Customize Auth0"

  Scenario: Create GitHub new integration
    Given they go to the developer portal users sso integrations page
    And they follow "GitHub"
    And they follow "Edit"
    When the form is submitted with:
      | Client        | Doctor |
      | Client Secret | tardis |
    Then they should see the flash message "Authentication provider updated"
    And the current page is the developer portal sso integration page

  Scenario: Client Secret is required
    Given they go to the developer portal new sso integration page for "keycloak"
    And there is a required field "Client Secret"
    When the form is submitted with:
      | Client        | Doctor                                     |
      | Client Secret |                                            |
      | Realm         | https://rh-sso.doctor.com/auth/realms/demo |
    Then they should see the flash message "Authentication provider has not been updated"
    And field "Client Secret" has inline error "can't be blank"

  Scenario: Client is required
    Given they go to the developer portal new sso integration page for "keycloak"
    And there is a required field "Client"
    When the form is submitted with:
      | Client        |                                            |
      | Client Secret | tardis                                     |
      | Realm         | https://rh-sso.doctor.com/auth/realms/demo |
    Then they should see the flash message "Authentication provider has not been updated"
    And field "Client" has inline error "can't be blank"

  Scenario: Realm is required
    Given they go to the developer portal new sso integration page for "keycloak"
    And there is a required field "Client Secret"
    When the form is submitted with:
      | Client        | Doctor                 |
      | Client Secret | tardis                 |
      | Realm         |                        |
    Then they should see the flash message "Authentication provider has not been updated"
    And field "Realm" has inline error "can't be blank"

  Scenario: Realm is required
    Given they go to the developer portal new sso integration page for "keycloak"
    When the form is submitted with:
      | Client        | Doctor |
      | Client Secret | tardis |
      | Realm         |        |
    Then they should see the flash message "Authentication provider has not been updated"
    And field "Realm" has inline error "can't be blank"

  Scenario: Realm or Site validation
    Given they go to the developer portal new sso integration page for "keycloak"
    And there is a required field "Client Secret"
    When the form is submitted with:
      | Client        | Doctor     |
      | Client Secret | tardis     |
      | Realm         | not-an-url |
    Then they should see the flash message "Authentication provider has not been updated"
    And field "Realm" has inline error "Invalid URL format"

