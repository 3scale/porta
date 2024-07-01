@javascript
Feature: Account Settings > Users > SSO Integrations > Show

  Background:
    Given a provider is logged in
    And a single sign-on integration

  Scenario: Navigation
    Given they go to the users sso integrations page
    When they follow "Red Hat Single Sign-On"
    Then the current page is the SSO Integration page
    And should see "Red Hat Single Sign-On"

  Scenario: Client secret should be hidden
    Given they go to the users sso integrations page
    When they follow "Red Hat Single Sign-On"
    Then they should not see "tardis"
    And they should see the following details:
      | Client ID     | doctor                                     |
      | Client Secret | ******                                     |
      | Realm         | https://rh-sso.doctor.com/auth/realms/demo |
