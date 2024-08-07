@javascript
Feature: Account Settings > Users > SSO Integrations > Edit

  Background:
    Given a provider is logged in
    And a red hat single sign-on integration

  Scenario: Navigation
    Given they go to the users sso integrations page
    When they follow "Red Hat Single Sign-On"
    And the current page is the sso integration page
    And should see "Red Hat Single Sign-On"
    And they follow "edit"
    Then the current page is the edit rh sso integration page

  Scenario: Update a RH SSO integration
    When they go to the edit rh sso integration page
    And the form is submitted with:
      | Client                            | Rose Tyler                                     |
      | Client Secret                     | outdated-tardis                                |
      | Realm                             | https://rh-sso.rose-tyler.com/auth/realms/demo |
      | Skip ssl certificate verification | Yes                                           |
    Then they should see the flash message "SSO integration updated"

  Scenario: Missing field
    When they go to the edit rh sso integration page
    And the form is submitted with:
      | Client                            |                                                |
      | Client Secret                     | outdated-tardis                                |
      | Realm                             | https://rh-sso.rose-tyler.com/auth/realms/demo |
    Then they should see the flash message "SSO integration could not be updated"
