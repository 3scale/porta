@javascript
Feature: Account Settings > Users > SSO Integrations > New

  Background:
    Given a provider is logged in

  Scenario: Navigation
    Given they go to the users sso integrations page
    When they follow "Add a SSO integration"
    Then the current page is the new sso integration page

  Scenario: Navigation when there is an integration
    Given a red hat single sign-on integration
    And they go to the users sso integrations page
    Then they should not see "Add a SSO integration"
    And there should be a link to "Create a new SSO integration"

  Scenario: Empty state
    Given they go to the users sso integrations page
    Then they should see "No SSO integrations"
    And there should be a link to "Add a SSO integration"

  Scenario: Create RH SSO new integration
    Given they go to the new sso integration page
    When the form is submitted with:
      | SSO Provider  | Red Hat Single Sign-On                     |
      | Client        | Doctor                                     |
      | Client Secret | tardis                                     |
      | Realm or Site | https://rh-sso.doctor.com/auth/realms/demo |
    Then they should see the flash message "SSO integration created"
    And the current page is the sso integration page
    And should see "Red Hat Single Sign-On"

  Scenario: Create Auth0 new integration
    Given they go to the new sso integration page
    When the form is submitted with:
      | SSO Provider  | Auth0                    |
      | Client        | Doctor                   |
      | Client Secret | tardis                   |
      | Realm or Site | https://doctor.auth0.com |
    Then they should see the flash message "SSO integration created"
    And the current page is the sso integration page
    And should see "Auth0"

  Scenario: Realm or Site hint is accurate
    Given they go to the new sso integration page
    When they select "Red Hat Single Sign-On" from "SSO Provider"
    Then they should see "e.g. https://rh-sso.example.com/auth/realms/demo"
    When they select "Auth0" from "SSO Provider"
    Then they should see "e.g. https://XXXXX.auth0.com"

  Scenario: Client Secret is required
    Given they go to the new sso integration page
    And there is a required field "Client Secret"
    When the form is submitted with:
      | SSO Provider  | Red Hat Single Sign-On                     |
      | Client        | Doctor                                     |
      | Client Secret |                                            |
      | Realm or Site | https://rh-sso.doctor.com/auth/realms/demo |
    Then they should see the flash message "SSO integration could not be created"
    And field "Client Secret" has inline error "can't be blank"

  Scenario: Client is required
    Given they go to the new sso integration page
    And there is a required field "Client"
    When the form is submitted with:
      | SSO Provider  | Red Hat Single Sign-On                     |
      | Client        |                                            |
      | Client Secret | tardis                                     |
      | Realm or Site | https://rh-sso.doctor.com/auth/realms/demo |
    Then they should see the flash message "SSO integration could not be created"
    And field "Client" has inline error "can't be blank"

  # TODO: Investigate why Realm or site hasn't can't be blank error on Red Hat Single Sign-On option
  # Scenario: Realm or Site is required
  #   Given they go to the new SSO Integration page
  #   And there is a required field "Client Secret"
  #   When the form is submitted with:
  #     | SSO Provider  | Red Hat Single Sign-On |
  #     | Client        | Doctor                 |
  #     | Client Secret | tardis                 |
  #     | Realm or Site |                        |
  #   Then they should see the flash message "SSO integration could not be created"
  #   And field "Realm or Site" has inline error "can't be blank"

  Scenario: Realm or Site is required
    Given they go to the new sso integration page
    And there is a required field "Client Secret"
    When the form is submitted with:
      | SSO Provider  | Auth0 |
      | Client        | Doctor                 |
      | Client Secret | tardis                 |
      | Realm or Site |                        |
    Then they should see the flash message "SSO integration could not be created"
    And field "Realm or Site" has inline error "can't be blank"

  Scenario: Realm or Site validation
    Given they go to the new sso integration page
    And there is a required field "Client Secret"
    When the form is submitted with:
      | SSO Provider  | Red Hat Single Sign-On |
      | Client        | Doctor                 |
      | Client Secret | tardis                 |
      | Realm or Site | not-an-url             |
    Then they should see the flash message "SSO integration could not be created"
    And field "Realm or Site" has inline error "Invalid URL format"
