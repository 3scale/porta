@javascript
Feature: Account Settings > Users > SSO Integrations > Show

  Background:
    Given a provider is logged in

  Scenario: Navigation
    Given a red hat single sign-on integration
    When they go to the users sso integrations page
    And they follow "Red Hat Single Sign-On"
    Then the current page is the sso integration page
    And should see "Red Hat Single Sign-On"

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
      | Client Secret | ******                                      |
      | Realm         | https://rh-sso.doctor.com/auth/realms/demo |

  Scenario: Auth0 integration details
    Given an auth0 integration
    When they go to the users sso integrations page
    And they follow "Auth0"
    Then they should see the following details:
      | Client ID     | doctor                   |
      | Client Secret | ******                    |
      | Site          | https://doctor.auth0.com |
