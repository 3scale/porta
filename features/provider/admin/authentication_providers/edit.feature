@javascript
Feature: Audience > Developer Portal > Settings > SSO Integrations > Edit

  Background:
    Given a provider is logged in
    And the provider has "branding" switch allowed
    And the provider has "iam_tools" switch allowed
    And a developer portal red hat single sign-on integration

  Scenario: Navigation
    Given they go to the developer portal users sso integrations page
    When they follow "Red Hat Single Sign-On"
    And the current page is the developer portal sso integration page
    And should see "Red Hat Single Sign-On"
    And they follow "Edit"
    Then the current page is the developer portal edit rh sso integration page

  Scenario: Update a RH SSO integration
    When they go to the developer portal edit rh sso integration page
    And the form is submitted with:
      | Client ID                         | Rose Tyler                                     |
      | Client Secret                     | outdated-tardis                                |
      | Realm                             | https://rh-sso.rose-tyler.com/auth/realms/demo |
      | Skip SSL certificate verification | Yes                                            |
    Then they should see the flash message "Authentication provider updated"

  Scenario: Missing field
    When they go to the developer portal edit rh sso integration page
    And the form is submitted with:
      | Client ID     |                                                |
      | Client Secret | outdated-tardis                                |
      | Realm         | https://rh-sso.rose-tyler.com/auth/realms/demo |
    Then they should see the flash message "Authentication provider has not been updated"
