@javascript
Feature: Enforce SSO for all users

  As a provider admin, I want to remove password-based authentication for all my users and permit to
  sign in only with SSO.

  Background:
    Given a provider is logged in

  Scenario: There are no sso integrations
    When they go to the users sso integrations page
    Then they should not see "To disable password-based authentication, make sure you have a published SSO integration that was tested within the last hour. Then, sign in using SSO."

  Scenario: There's one sso hidden integration
    Given the provider has an sso integration for the admin portal
    But the sso integration is hidden
    When they go to the users sso integrations page
    Then they should see "To disable password-based authentication, make sure you have a published SSO integration that was tested within the last hour. Then, sign in using SSO."

  Scenario: There is a sso integrations published but not tested
    Given the provider has an sso integration for the admin portal
    And the sso integration is published
    When they go to the users sso integrations page
    Then they should see "To disable password-based authentication, make sure you have a published SSO integration that was tested within the last hour. Then, sign in using SSO."

  Scenario: There is a sso integrations published and tested
    Given the provider has an sso integration for the admin portal
    And the sso integration is published
    And the sso integration is tested
    When they go to the users sso integrations page
    Then they should not see "To disable password-based authentication, make sure you have a published SSO integration that was tested within the last hour. Then, sign in using SSO."

  Scenario: Disable password-based authentication for all users
    Given the provider has an sso integration for the admin portal
    And the sso integration is published
    And the sso integration is tested
    And the provider has sso disabled for all users
    When they go to the users sso integrations page
    And switch "Disable password-based authentication for all users of this account" on
    And press "Disable password-based authentication" within the modal
    Then they should see a toast alert with text "Password-based authentication disabled"

  Scenario: Enable password-based authentication for all users
    Given the provider has an sso integration for the admin portal
    And the sso integration is published
    And the sso integration is tested
    And the provider has sso enabled for all users
    When they go to the users sso integrations page
    And switch "Disable password-based authentication for all users of this account" off
    And press "Enable password-based authentication" within the modal
    Then they should see a toast alert with text "Password-based authentication enabled"

  Scenario: Re-enabling password sign-ins should always be possible
    Given the provider has sso enabled for all users
    When they go to the users sso integrations page
    And switch "Disable password-based authentication for all users of this account" off
    And press "Enable password-based authentication" within the modal
    Then they should see a toast alert with text "Password-based authentication enabled"
