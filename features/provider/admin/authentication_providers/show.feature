@javascript
Feature: Audience > Developer Portal > Settings > SSO Integrations > Show

  Background:
    Given a provider is logged in
    And the provider has "branding" switch allowed
    And the provider has "iam_tools" switch allowed

  Scenario: RH SSO Navigation
    Given a developer portal red hat single sign-on integration
    When they go to the developer portal users sso integrations page
    And they follow "Red Hat Single Sign-On"
    Then the current page is the developer portal sso integration page
    And should see "Red Hat Single Sign-On"

  Scenario: Auth0 Navigation
    Given a developer portal auth0 integration
    When they go to the developer portal users sso integrations page
    And they follow "Auth0"
    Then the current page is the developer portal sso integration page
    And should see "Auth0"

  Scenario: GitHub Navigation
    Given a developer portal github integration
    When they go to the developer portal users sso integrations page
    And they follow "GitHub"
    Then the current page is the developer portal sso integration page
    And should see "GitHub"

  Scenario: Client secret should be *****
    Given a red hat single sign-on integration
    When they go to the users sso integrations page
    When they follow "Red Hat Single Sign-On"
    Then they should see the following details:
      | Client Secret | ****** |

  Scenario: Red Hat Single Sign-On integration details
    Given a red hat single sign-on integration
    When they go to the users sso integrations page
    And they follow "Red Hat Single Sign-On"
    Then they should see the following details:
      | Client ID     | doctor                                     |
      | Client Secret | ******                                     |
      | Realm         | https://rh-sso.doctor.com/auth/realms/demo |

  Scenario: Auth0 integration details
    Given an auth0 integration
    When they go to the users sso integrations page
    And they follow "Auth0"
    Then they should see the following details:
      | Client ID     | doctor                   |
      | Client Secret | ******                   |
      | Site          | https://doctor.auth0.com |
